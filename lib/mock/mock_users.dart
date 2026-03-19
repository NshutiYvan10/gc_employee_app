class MockUser {
  static const currentUser = {
    'employeeId': 'GC-2847',
    'legalName': 'Jonathan D. Mitchell',
    'preferredName': 'Jon',
    'email': 'jonathan.mitchell@gc.adventist.org',
    'phone': '+1 (301) 680-6000',
    'jobTitle': 'Senior Financial Analyst',
    'department': 'Treasury',
    'hireDate': '2018-03-15',
    'manager': 'Rebecca S. Torres',
    'managerTitle': 'Director of Treasury Operations',
    'managerEmail': 'rebecca.torres@gc.adventist.org',
    'employmentType': 'Full-Time',
    'workSchedule': 'Mon-Thu (8:00 AM - 5:30 PM)',
    'officeLocation': 'GC Building, Room 342',
    'avatarInitials': 'JM',
    'role': 'manager',
    'costCenter': 'CC-1040-TRES',
    'payGrade': 'Grade 14',
    'emergencyContact': {
      'name': 'Sarah K. Mitchell',
      'relationship': 'Spouse',
      'phone': '+1 (301) 555-0142',
    },
    'certifications': [
      'CPA - Certified Public Accountant',
      'CGMA - Chartered Global Management Accountant',
    ],
  };

  static const directReports = [
    {
      'employeeId': 'GC-3412',
      'name': 'Marcus L. Chen',
      'jobTitle': 'Financial Analyst I',
      'department': 'Treasury',
      'email': 'marcus.chen@gc.adventist.org',
      'avatarInitials': 'MC',
    },
    {
      'employeeId': 'GC-3587',
      'name': 'Priya N. Sharma',
      'jobTitle': 'Financial Analyst II',
      'department': 'Treasury',
      'email': 'priya.sharma@gc.adventist.org',
      'avatarInitials': 'PS',
    },
    {
      'employeeId': 'GC-3901',
      'name': 'David A. Okonkwo',
      'jobTitle': 'Accounts Payable Specialist',
      'department': 'Treasury',
      'email': 'david.okonkwo@gc.adventist.org',
      'avatarInitials': 'DO',
    },
  ];
}
