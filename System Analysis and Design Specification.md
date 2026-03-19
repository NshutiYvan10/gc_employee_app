# GC Employee Mobile Application  
## System Analysis & Design Specification

---

## Contents

- [Executive Summary](#executive-summary)
- [1 Detailed Analysis of Integrated Enterprise Systems](#1-detailed-analysis-of-integrated-enterprise-systems)
  - [1.1 UKG (Ultimate Kronos Group) / Successor System](#11-ukg-ultimate-kronos-group--successor-system)
  - [1.2 HRS (Human Resource Services)](#12-hrs-human-resource-services)
  - [1.3 SunPlus & AASI (Financial/Treasury Systems)](#13-sunplus--aasi-financialtreasury-systems)
  - [1.4 Laserfiche (Document Management)](#14-laserfiche-document-management)
  - [1.5 GC Travel Request System](#15-gc-travel-request-system)
  - [1.6 GC Helpdesk & IT Asset Management](#16-gc-helpdesk--it-asset-management)
  - [1.7 ExpenseWire](#17-expensewire)
- [2 Core Module & Key Screen Design Specifications](#2-core-module--key-screen-design-specifications)
  - [2.1 Screen: Home Dashboard](#21-screen-home-dashboard)
  - [2.2 Screen: Personal Profile Dashboard](#22-screen-personal-profile-dashboard)
  - [2.3 Screen: Travel Budget Dashboard](#23-screen-travel-budget-dashboard)
  - [2.4 Screen: Digital Bulletin Board](#24-screen-digital-bulletin-board)
  - [2.5 Screen: My Devices Dashboard](#25-screen-my-devices-dashboard)
  - [2.6 Screen: IT Support Portal](#26-screen-it-support-portal)
  - [2.7 Screen: Expense Submission Form](#27-screen-expense-submission-form)
  - [2.8 Screen: Benefits Overview (V2 - Placeholder)](#28-screen-benefits-overview-v2---placeholder)
- [3 Global UX/UI & Technical Patterns](#3-global-uxui--technical-patterns)
  - [3.1 Navigation & Information Architecture](#31-navigation--information-architecture)
  - [3.2 Security & Authentication Flows](#32-security--authentication-flows)
  - [3.3 Data Synchronization & Offline Strategy](#33-data-synchronization--offline-strategy)
  - [3.4 Notification Framework](#34-notification-framework)
- [Appendix](#appendix)
  - [Design Tokens & Component Library Reference](#design-tokens--component-library-reference)
  - [API Integration Mapping Matrix](#api-integration-mapping-matrix)

---

## Executive Summary

This document serves as the foundational design and research blueprint for the GC Employee Mobile Application. Its primary goal is to bridge the gap between high-level requirements and a production-ready, high-fidelity prototype by conducting deep-dive research into each integrated backend system. The app acts as a unified mobile front-end, **not a backend rebuild**. Therefore, authentic understanding of each system's data models, user workflows, constraints, and real-world usage is critical to designing an accurate and intuitive interface.

The following sections provide the detailed analysis and screen-by-screen specifications required to inform every design decision in Figma, ensuring the prototype reflects genuine enterprise behavior and seamless system integration.

---

## 1 Detailed Analysis of Integrated Enterprise Systems

### 1.1 UKG (Ultimate Kronos Group) / Successor System

**Primary Function:** End-to-end Human Capital Management (HCM), encompassing Workforce Management (time & attendance, scheduling) and HR/Payroll.

**Real-World Operation:** UKG is typically accessed via a comprehensive web portal. Employees use it for daily time tracking (punch in/out, view timesheets), requesting time off, viewing pay stubs, and updating W-4/Tax forms. Managers use it for scheduling, approving timecards/requests, and running team reports.

**Core Modules/Features:**
- **Time & Labor:** Timesheets, shift schedules, attendance points, punch corrections.
- **Human Resources:** Personal profile (contact info, dependents), job history, org chart.
- **Payroll:** Pay statements (stubs), earning history, tax documents (W-2, year-end), direct deposit info.
- **Benefits:** Enrollment (often during open enrollment periods), coverage summaries.
- **Talent & Performance:** Goal setting, performance reviews (not always used by all orgs).

**Key Data Structures:** Employee ID, Pay Codes, Earnings/Deductions, PTO Accrual Balances, Schedule Shifts, Position Data.

**Mobile Integration Realities:**
- UKG Dimensions/Pro offers robust RESTful APIs (e.g., Employee, Payroll, Time Management APIs). The mobile app should use these for **read** operations (view pay stub, check PTO balance) and **limited write** operations (submit time-off request, report time).
- **Data Sensitivity:** Payroll data is highly sensitive. Display must be secure, and any write action (like a time-off request) must trigger the system's native approval workflow.
- **UI Expectations:** Employees expect to see familiar terminology: "Pay Statement," "Request Time Off," "Accrual Balance." Design should mirror UKG's data hierarchy but with a mobile-optimized layout.

---

### 1.2 HRS (Human Resource Services)

**Primary Function:** Often a custom or legacy system for core HRIS functions—maintaining the "system of record" for employee master data (personal details, employment status, position, salary grade).

**Real-World Operation:** Primarily an administrative backend for HR staff. Employees rarely interact with it directly; data flows from HRS to other systems like UKG (for payroll) and Active Directory (for login credentials). It's the source of truth for legal name, hire date, job title, department, and manager.

**Core Modules/Features:**
- Employee Master Records
- Position Management
- Organizational Hierarchy
- Compliance Reporting

**Key Data Structures:** Employee ID (links all systems), Legal Name, Hire Date, Job Code, FLSA Status, Manager ID, Department Code.

**Mobile Integration Realities:**
- Likely requires data synchronization (batch or real-time via API) rather than direct user-facing API calls.
- The mobile app's **"Personal Profile"** will be a composite view, pulling "legal name" from HRS and "preferred name/address" from UKG. Updates to legal data may need to follow a change request process, not direct edit.
- The **"Org Chart"** feature, if required later, would source its structure from HRS.

---

### 1.3 SunPlus & AASI (Financial/Treasury Systems)

**Primary Function:** Core financial management, General Ledger (GL), Accounts Payable (AP), and budget tracking. SunPlus is likely the main GL; AASI might handle specific reimbursements or expense modules.

**Real-World Operation:** Finance staff use these systems to post journal entries, manage budgets by cost center, and process vendor/employee payments. Employees do not log into these systems directly. Their interaction is indirect: a travel request generates a budget encumbrance; an expense report generates an AP invoice.

**Core Modules/Features:** General Ledger, Cost Center Accounting, Accounts Payable, Budget Management.

**Key Data Structures:** Cost Center, GL Account Code, Budget Amount, Actual Spend, Encumbrance (committed funds), Invoice/Voucher Number.

**Mobile Integration Realities:**
- **Read-Only for Budget Data:** The app's **"Travel Budget Dashboard"** will need a secure API to fetch real-time budget vs. actual vs. encumbrance data for the user's cost center(s).
- **Write for Payments:** Expense reimbursements (FR-EX-005) require a complex API integration where a submitted, approved expense in the mobile app/ExpenseWire creates a "payable" record in SunPlus/AASI.
- **Constraint:** Financial data is heavily permission-based. A regular employee can only see budgets for their own cost centers; managers may see their team's aggregate.

---

### 1.4 Laserfiche (Document Management)

**Primary Function:** Enterprise Content Management (ECM) for storing, retrieving, and managing digital documents (PDFs, scanned images, office files).

**Real-World Operation:** Acts as a secure digital filing cabinet. HR stores employee handbooks, signed offer letters, and policy PDFs. Finance stores invoices. Employees might search for old travel reimbursement receipts.

**Core Modules/Features:** Document Repository, Full-Text Search, Version Control, Metadata Tagging (e.g., Employee ID, Document Type, Year).

**Key Data Structures:** Document ID, File Name, MIME Type, Metadata Fields, Folder Path.

**Mobile Integration Realities:**
- **API Access:** Laserfiche has a strong REST API. The app can query for documents tagged with the user's Employee ID (FR-HR-006).
- **UI Pattern:** The app should present a filterable, searchable list of personal documents (e.g., "2023 W-2," "Employee Handbook"). Tapping an item triggers a secure download and in-app preview (using a secure PDF viewer).
- **Offline Consideration:** Downloading large documents for offline access should be a user-initiated action with clear storage warnings.

---

### 1.5 GC Travel Request System  
*(apps.gc.adventist.org/TravelRequest)*

**Primary Function:** A custom web application for end-to-end travel authorization, budgeting, and itinerary management.

**Real-World Workflow:**
1. **Employee Submits:** Enters trip purpose, dates, destination, estimated airfare/lodging/meals.
2. **Budget Check:** System checks against the traveler's assigned budget (pulls from SunPlus).
3. **Approval Routing:** Goes to Manager → Department Head → Travel Office (multi-level).
4. **Post-Trip:** Expenses are tied back to the approved request for reconciliation.

**Core Modules/Features:** Request Form, Approval Workflow Engine, Budget Integration, Trip History, Spouse Travel Tracking.

**Key Data Structures:** Travel Request ID, Trip Purpose, Dates, Destinations, Estimated Costs, Approval Status, Budget Impact.

**Mobile Integration Realities (FR-TR-007):**
- The mobile app must replicate the exact same form and workflow via API. The **"Mobile Travel Request Submission"** screen is a mobile-optimized version of the existing web form.
- **Critical UI Need:** The **"Budget Impact Preview"** (FR-TR-008) must be prominent, showing real-time calculation before submission.
- **Manager View:** The **"Manager Approval Queue"** must allow batch actions (approve/all/reject) and display the same details (trip purpose, budget impact) as the web system.

---

### 1.6 GC Helpdesk & IT Asset Management

**Primary Function:** IT Service Management (ITSM) for logging and tracking support tickets, and an inventory system for tracking hardware lifecycles.

**Real-World Operation:** Employees email or call the helpdesk. Tickets are logged in a system like ServiceNow, Jira, or Zendesk. A separate asset database tracks laptop serial numbers, assignment dates, and warranty info.

**Core Modules/Features:** Ticket Creation, Assignment, Status Updates, Knowledge Base, Asset Inventory, Procurement Lifecycle.

**Key Data Structures:** Ticket Number, Category, Priority, Status, Asset Tag, Serial Number, Purchase Date, Warranty Expiry.

**Mobile Integration Realities:**

**Two Integration Points:**
1. **Helpdesk API/Email:** Submit a ticket with category/description. Fetch status (FR-IT-001/003).
2. **Asset Management API:** Pull a read-only list of devices assigned to the user (FR-DM-001).

- **UI for Tickets:** Should show a conversational thread, including technician updates.
- **UI for Devices:** Focus on visual status indicators. A progress bar/outbound timer showing *'2 years until refresh'* is more intuitive than just a date.

---

### 1.7 ExpenseWire

**Primary Function:** A specialized cloud-based expense report management system.

**Real-World Workflow:**
1. Employee creates a report, adds line items (meals, lodging, transport), and attaches receipt photos.
2. System performs policy checks (e.g., meal limits).
3. Report routes for manager approval.
4. Upon approval, data is sent to the financial system (SunPlus/AASI) for payment.

**Core Modules/Features:** Expense Report Creation, Receipt Capture (mobile app), Policy Compliance, Approval Workflow, Integration with Credit Cards & GL.

**Key Data Structures:** Expense Report ID, Line Items (Date, Category, Vendor, Amount, Payment Type, Purpose), Receipt Images, Approval Status.

**Mobile Integration Realities:**
- The requirement (FR-EX-001) suggests deep API integration. The GC app's **"Expense Submission"** form would essentially be a branded UI that posts data directly to ExpenseWire's API.
- **Key Design Implication:** The form must support **multiple expense line items** within a single report. It should mirror ExpenseWire's required fields: Date, Vendor, Category, Amount, Payment Type, Business Purpose.
- **Receipt Capture:** The in-app camera should allow multi-receipt capture and attach them to the correct line item.

---

## 2 Core Module & Key Screen Design Specifications

### 2.1 Screen: Home Dashboard

**Purpose:** Personalized launchpad showing actionable alerts, key metrics, and quick access to core functions.

**Target User:** All Employees (personalized content based on role).

**Data Displayed & Source Systems:**
- **Pending Actions Card:** Number of travel requests (Travel System) and expense reports (ExpenseWire) awaiting approval (For Managers).
- **Quick Metrics:**
  - Available PTO Balance (UKG API)
  - Current Travel Budget Balance (SunPlus API via Travel System)
  - Open IT Tickets (Helpdesk API)
- **Announcements Feed:** Latest 3-5 items (Communications Module DB).
- **Upcoming Travel Card:** Next approved trip (Travel System).

**UI Components:** Welcome header (name), Metric widgets (cards with icons/values), Feed list, Quick Action buttons (Request Time Off, Submit Travel, Submit Expense, Get Help), "See All" links.

**Interaction Flow:** Tap metric card → drills to detailed module. Tap announcement → full-screen view. Swipe to refresh.

**Role-Based Rules:** "Pending Actions" card hidden for non-managers. "Team PTO Overview" widget added for managers.

**Empty State:** "Welcome! Complete your profile." or "No pending actions."

**API Dependencies:** Multiple concurrent calls on launch (UKG, Travel, Helpdesk, Comms). Implement graceful degradation if one API is slow.

---

### 2.2 Screen: Personal Profile Dashboard

**Purpose:** Single view of an employee's master data, aggregated from multiple systems.

**Target User:** All Employees.

**Data Displayed & Source Systems:**
- **Section 1 - Legal Info (HRS):** Employee ID, Legal Name, Hire Date, Job Title, Department.
- **Section 2 - Contact Info (UKG):** Preferred Name, Work Email, Phone, Office Location. **Editable fields**.
- **Section 3 - Employment Summary (UKG/HRS):** Manager Name, Employment Type (Full/Part-time), Work Schedule.
- **Section 4 - Quick Links:** Link to "Pay Statements" (UKG), "Documents" (Laserfiche), "Emergency Contacts" (UKG - V2).

**UI Components:** Profile header (photo/avatar), Collapsible sections, Read-only text fields, Editable text fields (with "Edit" toggle), Save/Cancel buttons, Link buttons.

**Interaction Flow:** Tap "Edit" → editable fields become active → "Save" triggers PATCH call to UKG API. Legal info fields are disabled or show "Contact HR to change" tooltip.

**Security:** Any update to contact info must be logged (NFR-SEC-007).

---

### 2.3 Screen: Travel Budget Dashboard  
*(within Travel Module)*

**Purpose:** Provide real-time, visual understanding of travel budget status.

**Target User:** Employees with a travel budget.

**Data Displayed & Source Systems:**
- **Visual Summary:** Donut/bar chart showing: Total Annual Budget, Spent YTD, Approved (Encumbered), Remaining Available (SunPlus API).
- **Detailed Table:** List of YTD trips with columns: Date, Purpose, Status, Total Cost (Actual or Estimated).
- **Spouse Travel Sub-card:** Status (Eligible/Not), Available Credits (Travel System - V2).

**UI Components:** Data visualization widget, Data table with sort/filter, Status badges, View Details button per row, 'Submit New Request' FAB.

**Interaction Flow:** Tap a trip in the table → navigates to 'Trip Detail' screen. Filter by year/status.

**Error State:** "Budget data unavailable. Please try again later."

---

### 2.4 Screen: Digital Bulletin Board  
*(Communications Feed)*

**Purpose:** Central hub for official announcements, policies, and events.

**Target User:** All Employees.

**Data Displayed & Source Systems:**
- **List Items:** Announcement Title, Preview Snippet, Publishing Department (e.g., 'HR'), Date/Time, Priority Flag (e.g., 'Urgent'), Attachment Indicator.
- **Data Source:** Internal CMS/DB for the Communications Module (FR-CM-001). Policy documents may be links to files in Laserfiche.

**UI Components:** Segmented filter control ('All', 'Announcements', 'Policies', 'Events'), Search bar, Card-based list, Priority highlight color.

**Interaction Flow:** Pull-to-refresh. Tap item → full-screen view with formatted text, images, and attachments. Tap attachment → secure preview/download.

**Offline Strategy (V2):** Cache the title and snippet of recent announcements for offline viewing.

---

### 2.5 Screen: My Devices Dashboard

**Purpose:** Give employees transparency into their assigned IT equipment and refresh cycle.

**Target User:** All Employees with company-issued hardware.

**Data Displayed & Source Systems:**
- **Device Cards (per asset):** Device Type Icon, Make/Model (Asset Mgmt API), Assignment Date, Status Indicator (Eligible, Upcoming in X months, Not Eligible).
- **Refresh Countdown:** Visual timeline or large number 'Months until refresh: 14' based on Assignment Date + Org Policy (e.g., 48 months).
- **Specifications (V2):** Expandable section with Serial Number, RAM, Storage, etc.

**UI Components:** Status badges (color-coded), Progress bar for refresh countdown, 'Request Equipment' button (V2).

**Interaction Flow:** Tap a device card → slides up a detail panel with more info and history (FR-DM-007, V2).

---

### 2.6 Screen: IT Support Portal  
*(Ticket Submission)*

**Purpose:** Streamlined mobile interface to submit and track IT issues.

**Target User:** All Employees.

**Data Displayed & Source Systems:**
- **Form Fields:** Issue Category (dropdown from Helpdesk API - e.g., "Password Reset," "Hardware," "Software"), Affected Device (pre-populated dropdown from My Devices list), Subject, Description, Attachment (photo of error).
- **Ticket List:** History of submitted tickets with #, Subject, Status, Last Updated.

**UI Components:** Form with dropdowns, text inputs, file attachment button, Submit button. List view for history.

**Interaction Flow:** Submitting form creates a ticket via Helpdesk API or sends a structured email. User receives push notification (FR-NT-001) on status change.

**Empty State (History):** "You haven't submitted any tickets yet."

---

### 2.7 Screen: Expense Submission Form

**Purpose:** Digitize the creation and submission of an expense report.

**Target User:** All Employees who incur business expenses.

**Data Displayed & Source Systems:**
- **Report Header:** Report Name (auto-generated: "Expense Report - [Date]"), Cost Center (auto-filled from HRS).
- **Line Item List:** Each item requires: Date, Expense Category (dropdown from ExpenseWire API), Vendor, Amount, Payment Type, Business Purpose, Receipt (attach).
- **Running Total:** Automatically calculated sum of line items.
- **Policy Tips:** Real-time validation (e.g., "Meals over $50 require receipt").

**UI Components:** Dynamic list (add/remove items), Inline calculator, Receipt thumbnail preview, "Add Receipt" button (opens camera/gallery), Policy warning banners, "Submit for Approval" button.

**Interaction Flow:** Tapping "Submit" validates data, then sends full report JSON + receipt images to ExpenseWire API (FR-EX-001). Success confirmation displays the new report's tracking number.

**Constraint:** Must handle image uploads robustly. Show upload progress per receipt.

---

### 2.8 Screen: Benefits Overview (V2 - Placeholder)

**Purpose:** Centralized access to view and manage benefit elections.

**Target User:** All Employees.

**UI Preview:** Card-based layout (FR-BN-001). Each card (Health, Dental, Retirement) shows Coverage Type, Plan Name, Last 4 of Policy #, and "Coverage Details" button. During Open Enrollment, cards would have a "Change Election" action.

**Integration Note:** This is a read-heavy, write-rarely module. Enrollment changes are complex transactions likely to remain in the primary UKG/successor web interface for the foreseeable future. The mobile view is for status checking and accessing provider contacts.

---

## 3 Global UX/UI & Technical Patterns

### 3.1 Navigation & Information Architecture

- **Primary Navigation:** Bottom tab bar (iOS)/Bottom navigation bar (Android) with 5-7 key icons: Home, Travel, Expenses, Devices, Support.  
  'More' (hamburger) menu contains: Profile, Communications, Benefits (V2), Settings.
- **Secondary Navigation:** Contextual 'Back', 'Filter', 'Search', and 'Add/New' FABs within modules.
- **Hierarchy Principle:** Home → Module → List/Summary View → Detail View → Action/Form.

---

### 3.2 Security & Authentication Flows

- **Initial Login:** Redirect to GC SSO page (web view). Upon success, receive token.
- **MFA:** Integrated into SSO flow. App must handle session expiry and re-authentication gracefully.
- **Biometric Prompt:** Post-SSO, prompt user to "Enable Face ID/Touch ID for quicker access?" If enabled, subsequent app opens use biometrics to retrieve the stored session token.
- **Session Timeout:** After NFR-SEC-006 period, app locks. Requires biometric or PIN to reactivate session (without full SSO).

---

### 3.3 Data Synchronization & Offline Strategy

- **Online-First Design:** The app assumes connectivity. All write actions require live API calls.
- **Offline View (V2):** Cache critical read-only data on device: User Profile, Current PTO Balance, Travel Budget Summary. Implement a *'Last updated at...'* timestamp. On app launch with connectivity, refresh this cache in the background.
- **Queue for Offline Actions (Future Consideration):** Could queue actions like time-off requests if offline and sync when online, but this adds complexity and risk for transactional systems.

---

### 3.4 Notification Framework

- **Channel Strategy:**
  - **Push (High Priority):** Travel request approved/rejected, IT ticket updated, Urgent HR announcement.
  - **Email (All Critical):** Copy of every push notification.
  - **In-App Badging:** Numeric badges on Home tab and relevant module tabs (e.g., '2' on Travel tab for pending approvals).
- **Settings Screen (FR-NT-003):** Toggle switches per notification type (Travel, Expenses, IT, Announcements) and per channel (Push, Email).

---

## Appendix

### Design Tokens & Component Library Reference

*(To be defined in Figma but noted here for dev handoff)*

- **Colors:** Primary (GC Brand Blue), Success (Green), Warning (Amber), Error (Red), Neutrals (Gray Scale).
- **Typography:** Font Family (e.g., `-apple-system`, `Roboto`), Scale (Header-L, Body-M, Captions).
- **Spacing:** 4px base unit (8, 16, 24, 32, 48, 64).
- **Components:** Buttons (Primary, Secondary, Text), Cards (Elevated, Filled), Input Fields, Dropdowns, List Items, Status Badges.

---

### API Integration Mapping Matrix

| App Feature           | System        | API Endpoint (Example)                                      | Data Flow     | Auth Method  |
|-----------------------|---------------|------------------------------------------------------------|---------------|--------------|
| View Pay Stub         | UKG           | `GET /personnel/v1/employees/{id}/pay-statement`           | Read          | OAuth 2.0    |
| Submit Time Off       | UKG           | `POST /attendance/v1/employees/{id}/time-off-requests`     | Write         | OAuth 2.0    |
| Check Budget          | SunPlus       | `GET /api/budget-centers/{code}/summary`                  | Read          | API Key      |
| Fetch Documents       | Laserfiche    | `GET /v1/repositories/{repo}/entries?searchQuery=...`     | Read          | OAuth 2.0    |
| Submit Travel Request | Travel System | `POST /api/v2/travel-requests`                             | Write         | Token        |
| Create IT Ticket      | Helpdesk      | `POST /api/v2/tickets`                                     | Write         | Basic/Token  |
| Submit Expense        | ExpenseWire   | `POST /api/expense/reports`                                | Write         | OAuth 2.0    |

---

**Document Concludes**

This specification provides the depth of system understanding and screen-level detail required to proceed with a high-confidence, production-aligned Figma prototype. Each design decision can now be traced back to a real-world system constraint, data source, or user workflow.