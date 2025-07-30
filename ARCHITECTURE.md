The app now has comprehensive admin functionality for both expert and business profile management:

**Admin Dashboard Structure:**
- Main Admin Dashboard with navigation to different sections
- Pending Expert Approvals: Shows experts awaiting verification with full profile details and verification attachments
- Pending Business Approvals: Shows businesses awaiting verification with business documents and verification attachments
- Verified Accounts: Tabbed view showing both verified experts and verified businesses with profile dialogs
- Reports & Flags: Admin reporting and moderation tools

**Expert Profile Management:**
- Full profile display with bio, qualifications, work experience
- Verification attachments display (documents, images, links)
- Approval workflow with verify/request info/reject actions
- Profile dialog in verified accounts with attachment viewing

**Business Profile Management:**
- Business information display with description, website, legal documents
- Verification attachments display (business licenses, tax documents, certifications)
- Approval workflow with verify/request info/reject actions
- Business code generation and management
- Profile dialog in verified accounts with attachment viewing

**Data Models:**
- Expert model with verificationAttachments field
- Business model with verificationAttachments field (newly added)
- Consistent attachment structure across both models

**User Experience:**
- Expandable tiles for pending approvals with full details
- Tappable list items in verified accounts that show profile dialogs
- Consistent attachment display patterns
- Visual indicators for verification status
- Responsive design for various screen sizes

**Admin Workflow:**
- Complete visibility into verification documents
- Streamlined approval process
- Attachment viewing capabilities
- Status management for both experts and businesses
- Business code regeneration functionality

The architecture maintains consistency between expert and business profile management while providing comprehensive admin oversight capabilities.