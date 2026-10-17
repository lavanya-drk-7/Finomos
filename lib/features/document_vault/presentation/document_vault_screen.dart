import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../auth_kyc/providers/auth_kyc_provider.dart';
import '../../auth_kyc/domain/kyc_models.dart';
import '../domain/document_models.dart';
import '../providers/document_provider.dart';
import 'widgets/document_action_helper.dart';

class DocumentVaultScreen extends ConsumerStatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  ConsumerState<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends ConsumerState<DocumentVaultScreen> {
  final _searchController = TextEditingController();
  bool _isInitializedWithKyc = false;

  final List<String> _idTypes = [
    'PAN Card',
    'Aadhaar Card',
    'Driving License',
    'Passport',
    'Voter ID',
    'Bank Statement',
    'Salary Slip',
    'Form 16',
    'Insurance Policy',
    'Property Deed',
    'Mutual Fund CAS',
    'Other Govt ID',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitializedWithKyc) {
      _isInitializedWithKyc = true;
      // Sync KYC uploaded documents from registration
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final kycDocs = ref.read(authKycProvider).user.kycDocuments;
        if (kycDocs.isNotEmpty) {
          ref.read(documentVaultProvider.notifier).syncKycDocuments(kycDocs);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDocumentSheet(BuildContext context) {
    final existingDocs = ref.read(documentVaultProvider).documents;
    String selectedIdType = _idTypes.firstWhere(
      (type) => !existingDocs.any((d) => d.idType == type),
      orElse: () => 'Aadhaar Card',
    );
    final idNumberCtrl = TextEditingController();
    String uploadedFileName = '';
    String uploadedFileSize = '';
    String uploadedSource = '';
    String uploadedLocalPath = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add ID / Financial Document',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Select document type, enter number, and upload proof',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text('KYC Safe', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 1. Select ID Type Dropdown (Styled like Image 1)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select ID / Document Type *',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedIdType,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              items: _idTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.credit_card, size: 18, color: Color(0xFF0066FF)),
                                      const SizedBox(width: 10),
                                      Text(
                                        type,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A2540)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setSheetState(() {
                                    selectedIdType = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. ID / Document Number Field (Styled like Image 1)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$selectedIdType Number *',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          TextField(
                            controller: idNumberCtrl,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              border: InputBorder.none,
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0066FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.pin, size: 16, color: Color(0xFF0066FF)),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              hintText: 'Enter $selectedIdType Number',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Upload Document Box
                    Text(
                      'Upload $selectedIdType Document *',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                    ),
                    const SizedBox(height: 8),
                    if (uploadedFileName.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withOpacity(0.15),
                              ),
                              child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 36),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              uploadedFileName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Size: $uploadedFileSize • Ready to Save',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF059669)),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final result = await DocumentActionHelper.showDocumentSourcePickerSheet(
                                      context: sheetCtx,
                                      idType: selectedIdType,
                                      currentFileName: uploadedFileName,
                                      isReplace: true,
                                    );
                                    if (result != null) {
                                      setSheetState(() {
                                        uploadedFileName = result.fileName;
                                        uploadedFileSize = result.fileSize;
                                        uploadedSource = result.source;
                                        uploadedLocalPath = result.localPath ?? '';
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF059669)),
                                  label: const Text(
                                    'Replace Document',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    DocumentActionHelper.showDocumentPreviewDialog(
                                      context: sheetCtx,
                                      idType: selectedIdType,
                                      idNumber: idNumberCtrl.text.trim(),
                                      fileName: uploadedFileName,
                                      fileSize: uploadedFileSize,
                                      uploadSource: uploadedSource,
                                      localPath: uploadedLocalPath.isNotEmpty ? uploadedLocalPath : null,
                                    );
                                  },
                                  icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF0066FF)),
                                  label: const Text(
                                    'View Document',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF0066FF), width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: () async {
                          final result = await DocumentActionHelper.showDocumentSourcePickerSheet(
                            context: sheetCtx,
                            idType: selectedIdType,
                            isReplace: false,
                          );
                          if (result != null) {
                            setSheetState(() {
                              uploadedFileName = result.fileName;
                              uploadedFileSize = result.fileSize;
                              uploadedSource = result.source;
                              uploadedLocalPath = result.localPath ?? '';
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.4), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0066FF).withOpacity(0.1),
                                ),
                                child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF0066FF), size: 34),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Click here to upload $selectedIdType file',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Select from Gallery, Documents, File Manager, or Camera',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Save / Upload Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (uploadedFileName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select and upload a document proof first!'),
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          );
                          return;
                        }
                        final idNum = idNumberCtrl.text.trim();
                        final docNum = idNum.isNotEmpty ? idNum : 'ID-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                        // Categorize document
                        String cat = 'KYC & ID Proof';
                        if (selectedIdType.contains('Bank')) {
                          cat = 'Bank Statements';
                        } else if (selectedIdType.contains('Insurance')) {
                          cat = 'Insurance';
                        } else if (selectedIdType.contains('Form 16') || selectedIdType.contains('Tax')) {
                          cat = 'Tax & ITR';
                        } else if (selectedIdType.contains('Mutual Fund') || selectedIdType.contains('CAS')) {
                          cat = 'Investment';
                        }

                        final isKycDoc = cat == 'KYC & ID Proof';
                        final newDoc = VaultDocument(
                          id: 'vault_${DateTime.now().millisecondsSinceEpoch}',
                          name: uploadedFileName,
                          category: cat,
                          idType: selectedIdType,
                          documentNumber: docNum,
                          fileSize: uploadedFileSize.isNotEmpty ? uploadedFileSize : '1.8 MB',
                          uploadDate: 'Today',
                          fileUrl: uploadedLocalPath,
                          isUploaded: true,
                          isVerified: true,
                          isFromKyc: isKycDoc,
                        );

                        ref.read(documentVaultProvider.notifier).uploadDocument(newDoc);

                        if (isKycDoc) {
                          final user = ref.read(authKycProvider).user;
                          final existingList = user.kycDocuments.where((k) => k.idType != selectedIdType).toList();
                          final updatedKycList = [
                            ...existingList,
                            KycDocumentRecord(
                              id: newDoc.id,
                              idType: selectedIdType,
                              idNumber: docNum,
                              fileName: uploadedFileName,
                              fileSize: newDoc.fileSize,
                              fileUrl: uploadedLocalPath,
                              uploadDate: 'Today',
                              isUploaded: true,
                              isVerified: true,
                            ),
                          ];
                          ref.read(authKycProvider.notifier).updateUserData(user.copyWith(kycDocuments: updatedKycList));
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(child: Text('$selectedIdType added to Document Vault!')),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: const Text(
                        'Upload & Save to Vault',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showReplaceDialog(BuildContext context, VaultDocument doc) async {
    final result = await DocumentActionHelper.showDocumentSourcePickerSheet(
      context: context,
      idType: doc.idType,
      currentFileName: doc.name,
      isReplace: true,
    );

    if (result != null) {
      ref.read(documentVaultProvider.notifier).replaceDocument(
        doc.id,
        result.fileName,
        result.fileSize,
        result.localPath ?? '',
      );
      if (doc.isFromKyc) {
        final user = ref.read(authKycProvider).user;
        final updatedKyc = user.kycDocuments.map((k) {
          if (k.idType == doc.idType) {
            return k.copyWith(
              fileName: result.fileName,
              fileSize: result.fileSize,
              fileUrl: result.localPath ?? '',
              isUploaded: true,
            );
          }
          return k;
        }).toList();
        ref.read(authKycProvider.notifier).updateUserData(user.copyWith(kycDocuments: updatedKyc));
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${doc.idType} replaced from ${result.source}: ${result.fileName}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showViewDetailsDialog(BuildContext context, VaultDocument doc) {
    DocumentActionHelper.showDocumentPreviewDialog(
      context: context,
      idType: doc.idType,
      idNumber: doc.documentNumber,
      fileName: doc.name,
      fileSize: doc.fileSize,
      uploadDate: doc.uploadDate,
      uploadSource: 'Document Vault',
      localPath: doc.fileUrl.isNotEmpty ? doc.fileUrl : null,
      onReplace: () => _showReplaceDialog(context, doc),
      onDelete: () => _showDeleteUploadedFileOnlyDialog(context, doc),
    );
  }

  void _showDeleteEntireFieldDialog(BuildContext context, VaultDocument doc, int displayNumber) {
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
                'Delete Entire ID Document #$displayNumber?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'This will delete the entire ID Document #$displayNumber field (${doc.idType}) from your Document Vault.',
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
              ref.read(documentVaultProvider.notifier).deleteDocument(doc.id);
              if (doc.isFromKyc) {
                final user = ref.read(authKycProvider).user;
                final updatedKyc = user.kycDocuments.where((k) => k.idType != doc.idType).toList();
                ref.read(authKycProvider.notifier).updateUserData(user.copyWith(kycDocuments: updatedKyc));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ID Document #$displayNumber (${doc.idType}) field deleted'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Delete Field', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteUploadedFileOnlyDialog(BuildContext context, VaultDocument doc) {
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
          'Are you sure you want to delete only the uploaded file "${doc.name}"? The ${doc.idType} and document number (${doc.documentNumber}) will remain saved in Document Vault.',
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
              ref.read(documentVaultProvider.notifier).deleteUploadedFileOnly(doc.id);
              if (doc.isFromKyc) {
                final user = ref.read(authKycProvider).user;
                final updatedKyc = user.kycDocuments.map((k) {
                  if (k.idType == doc.idType) {
                    return k.copyWith(fileName: '', isUploaded: false, fileUrl: '');
                  }
                  return k;
                }).toList();
                ref.read(authKycProvider.notifier).updateUserData(user.copyWith(kycDocuments: updatedKyc));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Uploaded file removed for ${doc.idType}. ID details preserved.'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Remove File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    ref.listen(authKycProvider, (previous, next) {
      ref.read(documentVaultProvider.notifier).syncKycDocuments(next.user.kycDocuments);
    });

    final state = ref.watch(documentVaultProvider);

    final filteredDocs = state.documents.where((d) {
      final matchesCat = state.selectedCategoryFilter == 'All' ||
          d.category == state.selectedCategoryFilter ||
          (state.selectedCategoryFilter == 'KYC & ID Proof' && (d.category == 'KYC & ID Proof' || d.category == 'KYC' || d.category == 'PAN'));
      final matchesSearch = d.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          d.idType.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          d.documentNumber.toLowerCase().contains(state.searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0066FF)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const FinmosLogo(size: 26, showTagline: false, isHorizontal: true),
        actions: [
          IconButton(
            tooltip: 'Add Document',
            icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF0066FF)),
            onPressed: () => _showAddDocumentSheet(context),
          ),
        ],
      ),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document Vault',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Color(0xFF0A2540),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manage uploaded KYC proofs, tax documents & financial records',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'AES-256 Safe',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Storage Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A2540).withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF0066FF).withOpacity(0.12),
                              child: const Icon(Icons.folder_shared_outlined, size: 20, color: Color(0xFF0066FF)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.totalDocuments} Total Documents Stored',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Vault Space: ${state.storageUsedGB.toStringAsFixed(1)} GB of ${state.storageLimitGB.toStringAsFixed(0)} GB Used',
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${state.storagePercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0066FF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: state.storagePercentage / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar & Category Filter Pills
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => ref.read(documentVaultProvider.notifier).setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search by document name, ID or type...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF0066FF)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0066FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['All', 'KYC & ID Proof', 'Tax & ITR', 'Bank Statements', 'Insurance', 'Investment'].map((cat) {
                        final isSel = state.selectedCategoryFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => ref.read(documentVaultProvider.notifier).setCategoryFilter(cat),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF0066FF) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSel ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DOCUMENT CARDS LIST (Matching Image 1 Styling Exactly)
            if (filteredDocs.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.folder_open, size: 40, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text('No documents found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540))),
                    SizedBox(height: 4),
                    Text('Tap "+ Add Another ID Document" below to add documents.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              )
            else
              Column(
                children: List.generate(filteredDocs.length, (index) {
                  final doc = filteredDocs[index];
                  return _buildKycStyledDocumentCard(context, doc, index + 1);
                }),
              ),
            const SizedBox(height: 14),

            // "+ Add Another ID Document" Prominent Button (Exact design as Image 1)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => _showAddDocumentSheet(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0066FF), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFF0066FF), size: 18),
                    SizedBox(width: 4),
                    Text(
                      '+ Add Another ID Document',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

  // --------------------------------------------------------------------------
  // EXACT KYC-STYLED DOCUMENT CARD (Image 1 replica for each document)
  // --------------------------------------------------------------------------
  Widget _buildKycStyledDocumentCard(BuildContext context, VaultDocument doc, int displayNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: doc.isUploaded ? const Color(0xFF10B981).withOpacity(0.4) : const Color(0xFFE2E8F0),
          width: doc.isUploaded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Card Top Bar: Icon + ID Document #N + Uploaded Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF0066FF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID Document #$displayNumber',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (doc.isFromKyc)
                            const Text(
                              'Verified KYC Record',
                              style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (doc.isUploaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 13, color: Color(0xFF10B981)),
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
              IconButton(
                tooltip: 'Delete Entire Field',
                icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                onPressed: () => _showDeleteEntireFieldDialog(context, doc, displayNumber),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Select ID Type Field Box (Styled like Image 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select ID Type *',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.credit_card, size: 18, color: Color(0xFF0066FF)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        doc.idType,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. ID Number Box (Styled like Image 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${doc.idType} Number *',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.pin, size: 14, color: Color(0xFF0066FF)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.documentNumber.isNotEmpty ? doc.documentNumber : 'Verified Document',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Uploaded Document Box (Exact replica of Image 1 upload zone)
          Text(
            'Upload ${doc.idType} Document *',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
          ),
          const SizedBox(height: 6),
          if (doc.isUploaded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981).withOpacity(0.15),
                    ),
                    child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 34),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doc.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${doc.fileSize} • Uploaded on ${doc.uploadDate}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF059669)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () => _showReplaceDialog(context, doc),
                      icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF059669)),
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
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton.icon(
                            onPressed: () => _showViewDetailsDialog(context, doc),
                            icon: const Icon(Icons.visibility_outlined, size: 15, color: Color(0xFF0066FF)),
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
                          height: 38,
                          child: OutlinedButton.icon(
                            onPressed: () => _showDeleteUploadedFileOnlyDialog(context, doc),
                            icon: const Icon(Icons.delete_outline, size: 15, color: Color(0xFFEF4444)),
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
            InkWell(
              onTap: () => _showReplaceDialog(context, doc),
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
                    Text(
                      'Upload ${doc.idType} Document',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
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
                        onPressed: () => _showReplaceDialog(context, doc),
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
  }
}
