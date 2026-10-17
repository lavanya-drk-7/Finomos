import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_kyc/domain/kyc_models.dart';
import '../domain/document_models.dart';

class DocumentVaultNotifier extends Notifier<DocumentVaultState> {
  @override
  DocumentVaultState build() {
    return const DocumentVaultState(
      documents: [
        // Documents uploaded during KYC / Registration (1st image flow)
        VaultDocument(
          id: 'kyc_doc_pan',
          name: 'PAN_Card_Sireesha.pdf',
          category: 'KYC & ID Proof',
          idType: 'PAN Card',
          documentNumber: 'ABCDE1234F',
          fileSize: '1.2 MB',
          uploadDate: '30 Sep 2026',
          isUploaded: true,
          isVerified: true,
          isFromKyc: true,
        ),
        VaultDocument(
          id: 'kyc_doc_aadhaar',
          name: 'Aadhaar_Card_Sireesha.pdf',
          category: 'KYC & ID Proof',
          idType: 'Aadhaar Card',
          documentNumber: '•••• •••• 5678',
          fileSize: '2.4 MB',
          uploadDate: '30 Sep 2026',
          isUploaded: true,
          isVerified: true,
          isFromKyc: true,
        ),
        // Additional Financial & Tax Documents in PFOS
        VaultDocument(
          id: 'tax_doc_form16',
          name: 'Form_16_FY2025_26.pdf',
          category: 'Tax & ITR',
          idType: 'Form 16',
          documentNumber: 'TCS-FY2025-26',
          fileSize: '1.8 MB',
          uploadDate: '15 Jul 2026',
          isUploaded: true,
          isVerified: true,
        ),
        VaultDocument(
          id: 'bank_doc_stmt',
          name: 'HDFC_Bank_Statement_6M.pdf',
          category: 'Bank Statements',
          idType: 'Bank Statement',
          documentNumber: 'A/C ••••4587',
          fileSize: '3.5 MB',
          uploadDate: '01 Oct 2026',
          isUploaded: true,
          isVerified: true,
        ),
        VaultDocument(
          id: 'ins_doc_health',
          name: 'HDFC_ERGO_Health_Policy.pdf',
          category: 'Insurance',
          idType: 'Insurance Policy',
          documentNumber: 'POL-29837194',
          fileSize: '2.2 MB',
          uploadDate: '12 Aug 2026',
          isUploaded: true,
          isVerified: true,
        ),
        VaultDocument(
          id: 'inv_doc_cas',
          name: 'CAMS_Consolidated_Statement.pdf',
          category: 'Investment',
          idType: 'Mutual Fund CAS',
          documentNumber: 'CAS-998822',
          fileSize: '2.9 MB',
          uploadDate: '05 Oct 2026',
          isUploaded: true,
          isVerified: true,
        ),
      ],
      storageUsedGB: 2.8,
      storageLimitGB: 10.0,
    );
  }

  void syncKycDocuments(List<KycDocumentRecord> kycDocs) {
    final nonKycDocs = state.documents.where((d) => !d.isFromKyc).toList();

    final kycVaultDocs = kycDocs.map((kyc) {
      return VaultDocument(
        id: 'kyc_doc_${kyc.idType.toLowerCase().replaceAll(' ', '_')}',
        name: kyc.fileName,
        category: 'KYC & ID Proof',
        idType: kyc.idType,
        documentNumber: kyc.idNumber,
        fileSize: kyc.fileSize.isNotEmpty ? kyc.fileSize : '1.8 MB',
        fileUrl: kyc.fileUrl,
        uploadDate: kyc.uploadDate.isNotEmpty ? kyc.uploadDate : '30 Sep 2026',
        isUploaded: kyc.isUploaded,
        isVerified: kyc.isUploaded,
        isFromKyc: true,
      );
    }).toList();

    state = state.copyWith(
      documents: [...kycVaultDocs, ...nonKycDocs],
    );
  }

  void uploadDocument(VaultDocument doc) {
    state = state.copyWith(
      documents: [doc, ...state.documents],
      storageUsedGB: (state.storageUsedGB + 0.2).clamp(0.0, state.storageLimitGB),
    );
  }

  void replaceDocument(String id, String newFileName, String newFileSize, [String newFileUrl = '']) {
    final updated = state.documents.map((d) {
      if (d.id == id) {
        return d.copyWith(
          name: newFileName,
          fileSize: newFileSize,
          fileUrl: newFileUrl.isNotEmpty ? newFileUrl : d.fileUrl,
          uploadDate: 'Today',
          isUploaded: true,
        );
      }
      return d;
    }).toList();
    state = state.copyWith(documents: updated);
  }

  void renameDocument(String id, String newName) {
    final updated = state.documents.map((d) => d.id == id ? d.copyWith(name: newName) : d).toList();
    state = state.copyWith(documents: updated);
  }

  void deleteDocument(String id) {
    state = state.copyWith(
      documents: state.documents.where((d) => d.id != id).toList(),
      storageUsedGB: (state.storageUsedGB - 0.2).clamp(0.0, state.storageLimitGB),
    );
  }

  void deleteUploadedFileOnly(String id) {
    final updated = state.documents.map((d) {
      if (d.id == id) {
        return d.copyWith(
          isUploaded: false,
          name: '',
          fileSize: '',
          fileUrl: '',
        );
      }
      return d;
    }).toList();
    state = state.copyWith(documents: updated);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategoryFilter: category);
  }
}

final documentVaultProvider = NotifierProvider<DocumentVaultNotifier, DocumentVaultState>(() {
  return DocumentVaultNotifier();
});
