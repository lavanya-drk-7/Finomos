import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/kyc_models.dart';
import '../providers/auth_kyc_provider.dart';
import '../../document_vault/providers/document_provider.dart';
import '../../document_vault/presentation/widgets/document_action_helper.dart';
import 'flow_header.dart';

class IdDocumentItem {
  String idType;
  TextEditingController idNumberController;
  String fileName;
  String fileSize;
  String uploadSource;
  String localPath;
  bool isUploaded;

  IdDocumentItem({
    required this.idType,
    required String idNumber,
    required this.fileName,
    this.fileSize = '1.8 MB',
    this.uploadSource = 'Documents',
    this.localPath = '',
    this.isUploaded = false,
  }) : idNumberController = TextEditingController(text: idNumber);

  void dispose() {
    idNumberController.dispose();
  }
}

class KycDetailsScreen extends ConsumerStatefulWidget {
  const KycDetailsScreen({super.key});

  @override
  ConsumerState<KycDetailsScreen> createState() => _KycDetailsScreenState();
}

class _KycDetailsScreenState extends ConsumerState<KycDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _idTypes = [
    'PAN Card',
    'Aadhaar Card',
    'Driving License',
    'Passport',
    'Voter ID',
    'Other Govt ID',
  ];

  late List<IdDocumentItem> _documents;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authKycProvider).user;

    if (user.kycDocuments.isNotEmpty) {
      _documents = user.kycDocuments
          .map((kd) => IdDocumentItem(
                idType: kd.idType,
                idNumber: kd.idNumber,
                fileName: kd.fileName,
                fileSize: kd.fileSize,
                localPath: kd.fileUrl,
                isUploaded: kd.isUploaded,
              ))
          .toList();
    } else {
      _documents = [
        IdDocumentItem(
          idType: 'PAN Card',
          idNumber: user.panNumber.isEmpty ? 'ABCDE1234F' : user.panNumber,
          fileName: user.idProofFileName.isEmpty ? 'PAN_Card_Sireesha.pdf' : user.idProofFileName,
          fileSize: '1.8 MB',
          isUploaded: true,
        ),
      ];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncToVault();
    });
  }

  void _syncToVault() {
    final kycDocRecords = _documents.map((doc) {
      return KycDocumentRecord(
        id: 'kyc_${doc.idType.toLowerCase().replaceAll(' ', '_')}',
        idType: doc.idType,
        idNumber: doc.idNumberController.text.trim(),
        fileName: doc.fileName,
        fileSize: doc.fileSize,
        fileUrl: doc.localPath,
        isUploaded: doc.isUploaded,
        isVerified: doc.isUploaded,
        uploadDate: '30 Sep 2026',
      );
    }).toList();

    final user = ref.read(authKycProvider).user;
    final updatedUser = user.copyWith(
      kycDocuments: kycDocRecords,
    );
    ref.read(authKycProvider.notifier).updateUserData(updatedUser);
    ref.read(documentVaultProvider.notifier).syncKycDocuments(kycDocRecords);
  }

  @override
  void dispose() {
    for (var doc in _documents) {
      doc.dispose();
    }
    super.dispose();
  }

  void _addAnotherDocument() {
    final nextIdType = _idTypes.firstWhere(
      (type) => !_documents.any((doc) => doc.idType == type),
      orElse: () => 'Aadhaar Card',
    );

    String defaultNum = '';
    if (nextIdType == 'Aadhaar Card') {
      defaultNum = '9876 5432 1098';
    } else if (nextIdType == 'Driving License') {
      defaultNum = 'DL-1420110012345';
    } else if (nextIdType == 'Passport') {
      defaultNum = 'Z1234567';
    } else {
      defaultNum = 'ID-9988776655';
    }

    setState(() {
      _documents.add(
        IdDocumentItem(
          idType: nextIdType,
          idNumber: defaultNum,
          fileName: '',
          isUploaded: false,
        ),
      );
    });

    _syncToVault();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Added field for $nextIdType. Please select file & upload.',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0066FF),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickAndUploadDocument(int index, {bool isReplace = false}) async {
    final doc = _documents[index];
    final result = await DocumentActionHelper.showDocumentSourcePickerSheet(
      context: context,
      idType: doc.idType,
      currentFileName: doc.fileName,
      isReplace: isReplace,
    );

    if (result != null) {
      setState(() {
        doc.fileName = result.fileName;
        doc.fileSize = result.fileSize;
        doc.uploadSource = result.source;
        doc.localPath = result.localPath ?? '';
        doc.isUploaded = true;
      });
      _syncToVault();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isReplace
                      ? '${doc.idType} replaced from ${result.source}: ${result.fileName}'
                      : '${doc.idType} uploaded from ${result.source}: ${result.fileName}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _viewDocument(int index) {
    final doc = _documents[index];
    DocumentActionHelper.showDocumentPreviewDialog(
      context: context,
      idType: doc.idType,
      idNumber: doc.idNumberController.text.trim().toUpperCase(),
      fileName: doc.fileName,
      fileSize: doc.fileSize,
      uploadSource: doc.uploadSource,
      localPath: doc.localPath.isNotEmpty ? doc.localPath : null,
      onReplace: () => _pickAndUploadDocument(index, isReplace: true),
      onDelete: () => _deleteUploadedDocumentOnly(index),
    );
  }

  void _deleteEntireField(int index) {
    final doc = _documents[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Entire ID Document #${index + 1}?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'This will delete the entire ID Document #${index + 1} field including ${doc.idType} and all entered data.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                if (_documents.length > 1) {
                  final removed = _documents.removeAt(index);
                  removed.dispose();
                } else {
                  doc.idType = 'PAN Card';
                  doc.idNumberController.clear();
                  doc.isUploaded = false;
                  doc.fileName = '';
                  doc.fileSize = '';
                  doc.localPath = '';
                }
              });
              _syncToVault();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ID Document #${index + 1} field deleted'),
                  backgroundColor: const Color(0xFFEF4444),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete Field', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteUploadedDocumentOnly(int index) {
    final doc = _documents[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Uploaded Document?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete only the uploaded file "${doc.fileName}"? The ${doc.idType} and entered ID number will remain intact.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                doc.isUploaded = false;
                doc.fileName = '';
                doc.fileSize = '';
                doc.localPath = '';
              });
              _syncToVault();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Uploaded file removed for ${doc.idType}. ID details preserved.'),
                  backgroundColor: const Color(0xFFEF4444),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Remove File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onPrevious() {
    ref.read(authKycProvider.notifier).updateStep(2);
    context.go('/user-details');
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      final hasUploaded = _documents.any((doc) => doc.isUploaded);
      if (!hasUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload at least 1 valid ID Document to proceed!'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      final panDoc = _documents.firstWhere(
        (doc) => doc.idType == 'PAN Card',
        orElse: () => _documents.first,
      );

      final kycDocRecords = _documents.where((doc) => doc.isUploaded).map((doc) {
        return KycDocumentRecord(
          id: 'kyc_${doc.idType.toLowerCase().replaceAll(' ', '_')}',
          idType: doc.idType,
          idNumber: doc.idNumberController.text.trim().toUpperCase(),
          fileName: doc.fileName,
          uploadDate: 'Today',
          fileSize: doc.fileSize,
          fileUrl: doc.localPath,
          isUploaded: true,
          isVerified: true,
        );
      }).toList();

      final user = ref.read(authKycProvider).user;
      final updated = user.copyWith(
        panNumber: panDoc.idNumberController.text.trim().toUpperCase(),
        idProofFileName: panDoc.fileName,
        kycDocuments: kycDocRecords.isNotEmpty ? kycDocRecords : user.kycDocuments,
      );
      ref.read(authKycProvider.notifier).updateUserData(updated);
      ref.read(documentVaultProvider.notifier).syncKycDocuments(updated.kycDocuments);
      ref.read(authKycProvider.notifier).updateStep(4);
      context.go('/consent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onPrevious();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const FlowHeader(activeStep: 3),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'KYC Verification & ID Proof',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2540),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select government ID type, enter ID number, and upload verification document',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 20),

                        // Document Cards List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _documents.length,
                          itemBuilder: (context, index) {
                            final doc = _documents[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: doc.isUploaded
                                      ? const Color(0xFF10B981).withOpacity(0.5)
                                      : const Color(0xFFE2E8F0),
                                  width: doc.isUploaded ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Row: Card Title, Uploaded Badge & Delete Option
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0066FF).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF0066FF)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'ID Document #${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0A2540),
                                          ),
                                        ),
                                      ),
                                      if (doc.isUploaded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                                              SizedBox(width: 4),
                                              Text(
                                                'Uploaded',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                        onPressed: () => _deleteEntireField(index),
                                        tooltip: 'Delete Entire Field',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // 1. SELECT ID TYPE DROPDOWN
                                  DropdownButtonFormField<String>(
                                    value: doc.idType,
                                    decoration: InputDecoration(
                                      labelText: 'Select ID Type *',
                                      prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF0066FF)),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    items: _idTypes
                                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          doc.idType = val;
                                        });
                                        _syncToVault();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // 2. ID NUMBER INPUT FIELD (with 123 badge icon)
                                  TextFormField(
                                    controller: doc.idNumberController,
                                    textCapitalization: TextCapitalization.characters,
                                    onChanged: (_) => _syncToVault(),
                                    decoration: InputDecoration(
                                      labelText: '${doc.idType} Number *',
                                      hintText: 'Enter valid ${doc.idType} number',
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0066FF).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
                                          ),
                                          child: const Text(
                                            '123',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0066FF),
                                            ),
                                          ),
                                        ),
                                      ),
                                      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter ${doc.idType} number' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // 3. UPLOAD DOCUMENT SECTION
                                  Text(
                                    'Upload ${doc.idType} Document *',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                  ),
                                  const SizedBox(height: 8),

                                  if (doc.isUploaded)
                                    // MATCHING EXACT SCREENSHOT CARD (Green checkmark, filename, Replace, View, Delete)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFF10B981).withOpacity(0.7),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          // Green checkmark icon
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFF10B981).withOpacity(0.15),
                                            ),
                                            child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 40),
                                          ),
                                          const SizedBox(height: 10),

                                          // Filename in bold green
                                          Text(
                                            doc.fileName.isNotEmpty ? doc.fileName : '${doc.idType.replaceAll(' ', '_')}.pdf',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF065F46),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${doc.fileSize} • Uploaded via ${doc.uploadSource}',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF059669)),
                                          ),
                                          const SizedBox(height: 14),

                                          // Replace Document Button (Exact Image 1 design)
                                          SizedBox(
                                            width: double.infinity,
                                            height: 44,
                                            child: OutlinedButton.icon(
                                              onPressed: () => _pickAndUploadDocument(index, isReplace: true),
                                              icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF059669)),
                                              label: const Text(
                                                'Replace Document',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                backgroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // View Document and Delete Document Action Row
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => _viewDocument(index),
                                                    icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF0066FF)),
                                                    label: const Text(
                                                      'View Document',
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      side: const BorderSide(color: Color(0xFF0066FF), width: 1.2),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      backgroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => _deleteUploadedDocumentOnly(index),
                                                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                                                    label: const Text(
                                                      'Delete',
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      backgroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    // WHEN NOT YET UPLOADED: Clickable Upload Zone
                                    InkWell(
                                      onTap: () => _pickAndUploadDocument(index, isReplace: false),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0066FF).withOpacity(0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF0066FF)),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Upload Document',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'Choose from Gallery, Documents or File Manager',
                                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              height: 38,
                                              child: ElevatedButton.icon(
                                                onPressed: () => _pickAndUploadDocument(index, isReplace: false),
                                                icon: const Icon(Icons.upload_file, size: 16),
                                                label: const Text('Upload Document', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF0066FF),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                        // ADD ANOTHER ID & DOCUMENT BUTTON
                        OutlinedButton.icon(
                          onPressed: _addAnotherDocument,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            '+ Add Another ID Document',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0066FF),
                            side: const BorderSide(color: Color(0xFF0066FF), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ACTION BUTTONS ROW: PREVIOUS & NEXT
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: _onPrevious,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back, size: 18),
                                        SizedBox(width: 4),
                                        Text('Previous', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _onNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0066FF),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Next', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
