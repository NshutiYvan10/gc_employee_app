# GC Employee App Development Requirements Document

**Document Type:** Development Requirements Specification  
**Project Sponsor:** GC Treasurer  
**Project Manager:** Chief Information Officer (CIO)  
**Version:** 1.0  
**Classification:** Confidential – Internal  

*Project developed by the Chief Information Officer of the General Conference*

---

## 1. Executive Summary

The GC Employee App initiative aims to establish a unified mobile application for all General Conference collaborators. This strategic mobile platform will provide convenient access to essential services and information currently available through various web-based systems including UKG (and its successor), HRS, SunPlus (and AASI), Laserfiche, and the existing GC Travel Request system.

The project directly supports the GC's operational mission by extending mobile access to existing systems, enhancing efficiency, and elevating the overall employee experience. The deliverable will be native mobile applications published to both the Apple App Store (iOS) and Google Play Store (Android). A Progressive Web App (PWA) version may be considered in a Version 2 release, which will be a separate development project.

---

### Strategic Objectives

- Provide mobile access to employee information through integration with existing systems.
- Extend the current Travel Request system to mobile devices for on‑the‑go management.
- Improve internal communications through mobile‑accessible digital bulletin boards and notifications.
- Provide mobile access to employee benefits information.
- Enable mobile IT support ticket submission integrated with existing Helpdesk.
- Support the GC's mission through enhanced operational efficiency via mobile accessibility.

---

### Systems Integration Overview

| Current System       | Function                 | Integration Scope        |
|----------------------|--------------------------|--------------------------|
| UKG                  | HR Management & Payroll  | Read/Write Integration   |
| HRS                  | Human Resource Services  | Data Synchronization     |
| SunPlus              | Financial Management     | Budget & Expense Data    |
| Laserfiche           | Document Management      | Document Retrieval       |
| Travel Request System| Travel Authorization & Budget | API Integration      |
| GC Helpdesk          | IT Support Ticketing     | Email Submission or API  |

---

### Integration Architecture Note

**Important:** UKG is scheduled for replacement, and similar integration functionality will be required for the successor system. This UKG successor integration is designated as a **Version 2.0 release item**.

The application must be architected with **extensibility** as a core design principle, ensuring that integration points can be updated as backend systems are replaced over time. This modular integration approach applies to all system connections listed above. Provided that successor products maintain API access and adhere to standard integration protocols, the application should accommodate these transitions with minimal redevelopment effort. The development team should implement an **abstraction layer** for all external system integrations to facilitate future system migrations.

---

## 2. Current State Analysis & Pain Points

Through consultation with HR leadership and stakeholder analysis, the following operational challenges have been identified. These pain points relate primarily to mobile accessibility of existing systems rather than the absence of functionality. The GC has established web-based systems for most functions; this project extends mobile access to these existing solutions.

| ID        | Impact   | Description |
|-----------|----------|-------------|
| **PP-001** | HIGH     | **Limited Mobile Access to HR Information** – Employees must access desktop web applications (UKG, HRS, SunPlus, Laserfiche) to retrieve basic information. There is no unified mobile interface, limiting accessibility when away from a computer. |
| **PP-002** | HIGH     | **No Mobile Access to Travel Request System** – The existing Travel Request system (apps.gc.adventist.org/TravelRequest) is web-based only. Employees and managers cannot submit or approve travel requests from mobile devices, creating delays when traveling or away from desktop. |
| **PP-003** | HIGH     | **Travel Budget Visibility on Mobile** – While travel budget information is available in the web system, employees lack convenient mobile access to check their travel budget balance and usage history on‑the‑go. |
| **PP-004** | HIGH     | **Internal Communication Challenges** – No mobile-optimized digital channel exists for HR announcements, policy updates, event communications, and organizational updates to reach employees efficiently on their devices. |
| **PP-005** | MEDIUM   | **Limited Mobile Benefits Information Access** – Employees face difficulties accessing benefits information (insurance, retirement plans, support programs, scholarships) from mobile devices when not at their workstations. |

---

## 3. Functional Requirements

Requirements are classified as either **Version 1** or **Version 2**.  

- **Version 1** requirements represent the core functionality essential for the initial Minimum Viable Product (MVP) release and are mandatory for the first release.  
- **Version 2** requirements represent valuable enhancements to be developed in a subsequent project phase after Version 1 is successfully completed and deployed.  

This phased approach allows for measured investment and iterative improvement of the platform. A PWA web version is also designated as a Version 2 deliverable.

---

### 3.1 HR Information Centralization Module

This module serves as the foundation of the application, providing a unified dashboard for employees to access all HR-related information from a single interface.

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-HR-001** | **Personal Profile Dashboard** – Display employee personal information, contact details, and employment status in a consolidated view. | V1 |
| **FR-HR-002** | **Payroll Information Access** – Provide easy access to pay stubs, salary information, tax documents, and payment history. | V1 |
| **FR-HR-003** | **Vacation & Leave Management** – Display leave balances, allow leave requests, and show leave history and approvals. | V1 |
| **FR-HR-004** | **UKG System Integration** – Establish secure read/write API integration with UKG (and its successor) for real-time data synchronization. | V1 |
| **FR-HR-005** | **HRS Data Synchronization** – Implement data sync with HRS system for employee records and updates. | V1 |
| **FR-HR-006** | **Document Repository Access** – Enable retrieval of employee documents from Laserfiche document management system. | V2 |
| **FR-HR-007** | **Emergency Contact Management** – Allow employees to view and update emergency contact information. | V2 |

---

### 3.2 Travel Request & Budget Management Module

This module extends the existing GC Travel Request system (apps.gc.adventist.org/TravelRequest) to mobile devices. The current web-based travel authorization and budget management system will be integrated into the mobile app, providing employees and managers convenient access to travel functions on‑the‑go. This does **not** replace the existing system but provides a mobile interface to the same underlying functionality.

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-TR-001** | **Travel Budget Dashboard** – Display real-time travel budget balance, allocation, and remaining funds from existing Travel Request system. | V1 |
| **FR-TR-002** | **Travel History View** – Show complete history of approved trips including dates, destinations, and expenses from existing system. | V1 |
| **FR-TR-003** | **Spouse Travel Eligibility** – Display spouse travel eligibility status and accumulated credits from existing Travel Request system. | V2 |
| **FR-TR-004** | **Mobile Travel Request Submission** – Enable employees to submit travel requests via mobile, integrating with existing Travel Request system workflow. | V1 |
| **FR-TR-005** | **Existing Workflow Integration** – Integrate with existing multi-level approval workflow in the Travel Request system. | V1 |
| **FR-TR-006** | **Manager Mobile Approval** – Provide managers mobile interface to review, approve, or reject travel requests within existing system. | V1 |
| **FR-TR-007** | **Travel Request System API** – Establish secure API integration with existing Travel Request system at apps.gc.adventist.org. | V1 |
| **FR-TR-008** | **Budget Impact Preview** – Show projected budget impact before travel request submission. | V1 |
| **FR-TR-009** | **Travel Policy Reference** – Integrate travel policy documents accessible during request process. | V2 |

---

### 3.3 Digital Bulletin Board & Communications Module

This module establishes a central communication hub for organizational announcements, policies, and employee engagement content.

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-CM-001** | **Announcement Dashboard** – Display organizational announcements in a visually organized, prioritized feed. | V1 |
| **FR-CM-002** | **Policy Document Library** – Provide searchable repository for HR manuals, policies, and procedure documents. | V1 |
| **FR-CM-003** | **Event Calendar Integration** – Display upcoming organizational events, meetings, and important dates. | V1 |

---

### 3.4 Notifications & Alerts Module

This module ensures timely delivery of important information to employees through multiple communication channels.

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-NT-001** | **Push Notification System** – Implement push notifications for mobile app users with configurable preferences. | V1 |
| **FR-NT-002** | **Email Notification Integration** – Send notification copies via email for critical announcements. | V1 |
| **FR-NT-003** | **Notification Preferences** – Allow employees to configure notification channels and frequency preferences. | V1 |
| **FR-NT-004** | **Group Messaging** – Support targeted notifications to defined employee groups or departments. | V1 |
| **FR-NT-005** | **SMS Alert Capability** – Enable SMS delivery for urgent communications requiring immediate attention. | V2 |

---

### 3.5 Benefits Information & Management Module

This module provides comprehensive access to employee benefits information, enabling self-service management of benefit selections and enrollments.

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-BN-001** | **Benefits Overview Dashboard** – Display summary of all enrolled benefits with key details and coverage levels. | V2 |
| **FR-BN-002** | **Insurance Information** – Show health, dental, vision, and life insurance details, coverage, and provider contacts. | V2 |
| **FR-BN-003** | **Retirement Plan Access** – Display retirement plan information, contribution levels, and account balances. | V2 |
| **FR-BN-004** | **Open Enrollment Support** – Facilitate annual benefits enrollment with plan comparison tools. | V2 |
| **FR-BN-005** | **LifeCare Program Integration** – Provide access to LifeCare support program resources and contact information. | V2 |
| **FR-BN-006** | **Tuition Assistance Portal** – Enable access to educational assistance program information and application status. | V2 |
| **FR-BN-007** | **Scholarship Information** – Display available scholarship programs for employees and dependents. | V2 |
| **FR-BN-008** | **Dependent Management** – Allow employees to view and manage covered dependents. | V2 |

---

### 3.6 Expense & Reimbursement Module

This module digitizes the expense submission and reimbursement tracking process, integrating with treasury systems for efficient financial management. Integration via API with **ExpenseWire**.

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-EX-001** | **Expense Submission Form** – Enable digital submission of expenses with category selection, amounts, and descriptions via ExpenseWire. | V1 |
| **FR-EX-002** | **Receipt Image Capture** – Allow photo capture and upload of receipts directly from mobile device. | V2 |
| **FR-EX-003** | **Expense Categories** – Provide predefined expense categories aligned with organizational accounting codes. | V2 |
| **FR-EX-004** | **Reimbursement Status Tracking** – Display real-time status of submitted expenses through approval and payment process via ExpenseWire integration. | V2 |
| **FR-EX-005** | **Treasury System Integration** – Integrate with SunPlus, AASI, and other designated treasury systems for payment processing. | V2 |
| **FR-EX-006** | **Expense History Archive** – Maintain searchable history of all submitted and processed expenses. | V2 |
| **FR-EX-007** | **Manager Expense Review** – Provide supervisors interface to review and approve team expense submissions. | V2 |
| **FR-EX-008** | **Spending Reports** – Generate expense reports by category, date range, and cost center. | V2 |

---

### 3.7 Device Management & Refresh Tracking Module

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-DM-001** | **Device Inventory Dashboard** – Display all IT assets assigned to the employee including laptops, monitors, phones, and peripherals. | V1 |
| **FR-DM-002** | **Device Anniversary Tracking** – Show device assignment date and calculate anniversary/age for each assigned device. | V1 |
| **FR-DM-003** | **Refresh Eligibility Status** – Display refresh cycle eligibility status with clear indicators (eligible, upcoming, not yet eligible). | V1 |
| **FR-DM-004** | **Refresh Schedule Countdown** – Show countdown or timeline to next scheduled device refresh date based on organizational policy. | V1 |
| **FR-DM-005** | **Asset Management Integration** – Integrate with GC IT asset management system for real-time device data synchronization. | V1 |
| **FR-DM-006** | **Device Specifications View** – Display device details including make, model, serial number, and key specifications. | V2 |
| **FR-DM-007** | **Refresh History** – Show history of previous device refreshes and replacements for the employee. | V2 |
| **FR-DM-008** | **Equipment Request Submission** – Enable employees to submit requests for new equipment or accessories with justification. | V2 |
| **FR-DM-009** | **IT Asset Policy Reference** – Provide access to device refresh policies and equipment standards documentation. | V2 |

---

### 3.8 IT Support & Helpdesk Integration Module

This module provides employees with a basic mobile interface to submit IT support requests and view ticket history. It integrates with the existing GC Helpdesk solution and does not replace the current system. Integration may be achieved through API or email‑based submission.

| ID            | Requirement Description | Version |
|---------------|--------------------------|---------|
| **FR-IT-001** | **Support Request Submission** – Enable employees to submit IT support requests with issue category and description. | V1 |
| **FR-IT-002** | **Helpdesk System Integration** – Integrate with existing GC Helpdesk solution via API or email submission for ticket creation. | V1 |
| **FR-IT-003** | **Ticket Status Tracking** – Display current status of submitted support tickets (open, in progress, resolved). | V1 |

---

## 4. Non-Functional Requirements

### 4.1 Security Requirements

| ID               | Requirement Description | Version |
|------------------|--------------------------|---------|
| **NFR-SEC-001**  | **Authentication** – Integration with GC Active Directory/SSO for unified authentication. | V1 |
| **NFR-SEC-002**  | **Multi-Factor Authentication** – Require MFA for app login using approved methods (authenticator app, SMS, or biometric). | V1 |
| **NFR-SEC-003**  | **Biometric Authentication** – Support device biometric authentication (Face ID, Touch ID, fingerprint) as MFA factor. | V1 |
| **NFR-SEC-004**  | **Data Encryption** – All data transmission encrypted via TLS 1.3; sensitive data encrypted at rest. | V1 |
| **NFR-SEC-005**  | **Role-Based Access** – Implement RBAC with defined roles: Employee, Manager, HR Admin, System Admin. | V1 |
| **NFR-SEC-006**  | **Session Management** – Automatic session timeout after configurable idle period. | V1 |
| **NFR-SEC-007**  | **Audit Logging** – Comprehensive logging of all user actions and system events. | V1 |
| **NFR-SEC-008**  | **Data Privacy** – Compliance with applicable data protection regulations and church policies. | V1 |

---

### 4.2 Usability & Accessibility Requirements

| ID              | Requirement Description | Version |
|-----------------|--------------------------|---------|
| **NFR-UX-001**  | **Mobile-First Design** – Native mobile interface optimized for iOS and Android platforms. | V1 |
| **NFR-UX-002**  | **Accessibility** – WCAG 2.1 AA compliance for accessibility standards on mobile. | V1 |
| **NFR-UX-003**  | **Intuitive Navigation** – User interface requiring minimal training for adoption. | V1 |
| **NFR-UX-004**  | **Offline Capability** – Key information viewable offline with sync when connectivity restored. | V2 |

---

## 5. Technical Architecture Requirements

### 5.1 Platform Requirements

The application shall be developed as native mobile applications for iOS and Android platforms. The deliverables will be published to the Apple App Store and Google Play Store. A Progressive Web App (PWA) version may be considered as a separate follow‑up project to complement the mobile applications.

| ID              | Requirement Description | Version |
|-----------------|--------------------------|---------|
| **TR-PL-001**   | **iOS Mobile Application** – Native or cross‑platform app supporting iOS 14+ published to Apple App Store. | V1 |
| **TR-PL-002**   | **Android Mobile Application** – Native or cross‑platform app supporting Android 10+ published to Google Play Store. | V1 |
| **TR-PL-003**   | **App Store Compliance** – Meet all Apple App Store and Google Play Store submission requirements and guidelines. | V1 |
| **TR-PL-004**   | **Future PWA Consideration** – Architecture should support potential future PWA development as a complementary project. | V2 |

---

### 5.2 Integration Requirements

The following system integrations are required to achieve the unified employee experience outlined in this document. Integration approaches should prioritize **API‑based connections** where available.

| System          | Integration Type    | Data Flow     | Priority  |
|-----------------|---------------------|---------------|-----------|
| UKG (HR/Payroll)| API Integration     | Bidirectional | Critical  |
| HRS             | API/Database Sync   | Bidirectional | Critical  |
| SunPlus (Treasury)| API Integration   | Bidirectional | Critical  |
| Laserfiche (Documents)| API Integration | Read-Only     | High      |

---

## 6. User Interface Requirements

The mobile application interface shall follow modern dashboard design principles similar to business intelligence platforms (e.g., Power BI), emphasizing **data visualization, intuitive navigation, and clean visual hierarchy** optimized for mobile screens.

### 6.1 Dashboard Design Principles

- **Card‑based layout** for modular information presentation.
- **Data visualization widgets** for budgets, leave balances, and metrics.
- **Consistent color coding** for status indicators and priority levels.
- **Progressive disclosure** – summary views with drill‑down capability.
- **Quick action buttons** for frequently used functions.
- **Personalized dashboard** with customizable widget arrangement.
- **Clear visual hierarchy** distinguishing primary and secondary information.
- **Contextual help and tooltips** for user guidance.

### 6.2 Navigation Structure

The application shall implement a consistent navigation structure across all platforms:

| Navigation Level      | Elements                                                                 |
|-----------------------|--------------------------------------------------------------------------|
| **Primary Navigation**| Home Dashboard, My Profile, Travel, Communications, Benefits, Expenses, My Devices, IT Support |
| **Secondary Navigation**| Settings, Notifications, Search                                         |
| **Mobile Navigation** | Bottom tab bar for primary functions; hamburger menu or tab for secondary access |

### 6.3 Key Screen Wireframe Concepts

The following key screens should be developed with high‑fidelity prototypes for stakeholder review prior to development:

- **Home Dashboard** – personalized overview with key metrics and quick actions.
- **Travel Budget View** – visual budget representation with history timeline.
- **Travel Request Form** – step‑by‑step wizard with validation.
- **Communications Feed** – scrollable announcement feed with filtering.
- **Benefits Overview** – card‑based benefits summary with details expansion.
- **Expense Submission** – form with receipt capture and category selection.
- **My Devices Dashboard** – device inventory with refresh status indicators and countdown timers.
- **IT Support Portal** – ticket submission form with category selection and attachment upload.
- **Support Ticket Tracker** – list view of open/closed tickets with status and communication thread.
- **Manager Approval Queue** – list view with batch action capabilities.
- **Employee Profile** – comprehensive personal information display.

---

## 7. User Roles & Permissions

The application shall implement role‑based access control (RBAC) with the following defined user roles and their associated permissions.

| Role                   | Description                                      | Key Permissions                                                                                 |
|------------------------|--------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Employee**           | All GC staff members                             | View personal info, submit requests, access communications                                     |
| **Manager**            | Supervisory staff                               | Employee permissions + approve team requests, view team data                                   |
| **HR Administrator**   | Human Resources staff                           | Manage communications, view reports, configure benefits info                                   |
| **Travel Administrator**| Travel coordination staff                      | Manage travel budgets, override approvals, generate reports                                    |
| **Finance Administrator**| Treasury/Finance staff                        | Process reimbursements, manage expense categories, financial reports                           |
| **System Administrator**| IT administration                              | Full system access, user management, integration configuration                                 |

---

## 8. Appendix

### 8.1 Glossary of Terms

| Term                  | Definition                                                                                   |
|-----------------------|----------------------------------------------------------------------------------------------|
| **GC**                | General Conference of Seventh‑day Adventists                                                 |
| **UKG**               | Ultimate Kronos Group – HR and payroll management system                                     |
| **HRS**               | Human Resource Services – employee information system                                        |
| **SunPlus**           | Financial management and treasury system                                                     |
| **Laserfiche**        | Document management and imaging system                                                       |
| **Travel Request System** | Existing web-based travel authorization system at apps.gc.adventist.org                     |
| **GC Helpdesk**       | Existing IT support ticketing and management system                                          |
| **IT Asset Management** | System for tracking organizational IT equipment and lifecycle                               |
| **Device Refresh Cycle** | Scheduled replacement period for IT equipment (typically 3‑4 years)                        |
| **SSO**               | Single Sign‑On – unified authentication system                                               |
| **MFA**               | Multi‑Factor Authentication – additional security verification                               |
| **RBAC**              | Role‑Based Access Control                                                                    |
| **APNs**              | Apple Push Notification service                                                              |
| **FCM**               | Firebase Cloud Messaging (Android push notifications)                                        |
| **API**               | Application Programming Interface                                                            |

---

### 8.2 Key Stakeholders

| Role                    | Responsibility                                                              |
|-------------------------|-----------------------------------------------------------------------------|
| **Project Sponsor**     | Executive oversight and strategic direction                                 |
| **Project Manager (IT)**| Technical coordination and delivery management                              |
| **HR Director**         | HR requirements validation and user acceptance                              |
| **Treasury Representative** | Financial integration and expense workflow requirements                  |
| **End User Representatives** | User experience feedback and testing                                    |

---

### 8.3 Document Control

| Version | Date      | Author | Changes                                      |
|---------|-----------|--------|----------------------------------------------|
| 1.0     | February 2025 | CIO   | Initial requirements document               |
| 1.1     | February 2025 | CIO   | Added Device Mgmt, IT Support; clarified scope |

---