class MockTickets {
  static const tickets = [
    {
      'id': 'INC-28491',
      'subject': 'Outlook Calendar Not Syncing on iPhone',
      'category': 'Email & Collaboration',
      'status': 'in_progress',
      'priority': 'medium',
      'createdDate': '2026-03-17',
      'lastUpdated': '2026-03-18',
      'description':
          'My Outlook calendar on my iPhone (GC-PH-6340) stopped syncing as of Monday morning. '
          'New meetings added on desktop do not appear on the phone. I have tried restarting the app and the device.',
      'assignedTo': 'Kevin R. Patel',
      'messages': [
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-17T09:14:00',
          'text':
              'Calendar events created on my desktop Outlook are not showing up on my iPhone. '
              'This started this morning. Email sync appears fine, only calendar is affected.',
        },
        {
          'author': 'Kevin R. Patel',
          'role': 'technician',
          'date': '2026-03-17T11:30:00',
          'text':
              'Hi Jon, thanks for reporting this. This may be related to the Intune profile update '
              'pushed over the weekend. I am going to re-push the Exchange profile to your device. '
              'Please check in about an hour and let me know if it resolves.',
        },
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-17T14:05:00',
          'text': 'Still not syncing after the profile push. New events from today are missing.',
        },
        {
          'author': 'Kevin R. Patel',
          'role': 'technician',
          'date': '2026-03-18T08:45:00',
          'text':
              'I have escalated this to the Exchange team as we are seeing a few other reports. '
              'As a temporary workaround, you can use the Outlook mobile app (not the native calendar) '
              'which appears to be syncing correctly. I will update you once we have a fix.',
        },
      ],
    },
    {
      'id': 'INC-28387',
      'subject': 'VPN Disconnects Frequently When Working Remote',
      'category': 'Network & Connectivity',
      'status': 'resolved',
      'priority': 'high',
      'createdDate': '2026-03-10',
      'lastUpdated': '2026-03-14',
      'description':
          'GlobalProtect VPN drops connection every 15-20 minutes when working from home. '
          'This disrupts access to internal finance systems and shared drives.',
      'assignedTo': 'Lisa M. Thompson',
      'messages': [
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-10T08:22:00',
          'text':
              'VPN keeps disconnecting roughly every 15-20 minutes. I am on a stable home network '
              '(Verizon FiOS, 300 Mbps). This started after the maintenance window last weekend.',
        },
        {
          'author': 'Lisa M. Thompson',
          'role': 'technician',
          'date': '2026-03-10T10:15:00',
          'text':
              'Hi Jon, we are aware of intermittent VPN issues following the weekend maintenance. '
              'Can you please run the diagnostic tool (Start > GC Network Diagnostics) and send me the output file?',
        },
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-10T11:00:00',
          'text': 'Diagnostic file attached. Let me know what you find.',
        },
        {
          'author': 'Lisa M. Thompson',
          'role': 'technician',
          'date': '2026-03-12T09:30:00',
          'text':
              'The diagnostics showed a configuration mismatch from the server update. '
              'I have pushed an updated GlobalProtect configuration to your machine. '
              'Please restart your laptop and reconnect to VPN. This should resolve the drops.',
        },
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-14T16:00:00',
          'text':
              'VPN has been stable since the update on Thursday. No disconnections in the last two days. Thank you!',
        },
        {
          'author': 'Lisa M. Thompson',
          'role': 'technician',
          'date': '2026-03-14T16:30:00',
          'text': 'Great to hear. Marking this as resolved. Feel free to reopen if the issue returns.',
        },
      ],
    },
    {
      'id': 'INC-28445',
      'subject': 'Request: Install Adobe Acrobat Pro on Laptop',
      'category': 'Software Request',
      'status': 'open',
      'priority': 'low',
      'createdDate': '2026-03-14',
      'lastUpdated': '2026-03-14',
      'description':
          'Requesting Adobe Acrobat Pro DC to be installed on my MacBook Pro (GC-LP-4821). '
          'I need to edit and redact financial PDFs for the upcoming audit review.',
      'assignedTo': null,
      'messages': [
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-14T13:45:00',
          'text':
              'I need Adobe Acrobat Pro installed for editing and redacting PDF documents. '
              'My current Preview app cannot handle the redaction features I need for audit documents. '
              'Manager Rebecca Torres has approved the software request.',
        },
      ],
    },
    {
      'id': 'INC-28302',
      'subject': '3rd Floor Printer Jamming on Duplex Jobs',
      'category': 'Printing & Scanning',
      'status': 'closed',
      'priority': 'medium',
      'createdDate': '2026-03-03',
      'lastUpdated': '2026-03-06',
      'description':
          'The shared printer on the 3rd floor (HP LaserJet near Room 340) jams consistently '
          'when printing double-sided documents over 10 pages.',
      'assignedTo': 'Brian K. Vasquez',
      'messages': [
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-03T10:30:00',
          'text':
              'The 3rd floor HP printer near Room 340 jams every time I try to print duplex documents '
              'over about 10 pages. Single-sided printing works fine.',
        },
        {
          'author': 'Brian K. Vasquez',
          'role': 'technician',
          'date': '2026-03-04T08:00:00',
          'text':
              'Thanks for the report. The duplex unit on that printer has been flagged for service. '
              'A technician will be on-site Thursday to replace the paper feed rollers. '
              'In the meantime, please use the printer near Room 360.',
        },
        {
          'author': 'Brian K. Vasquez',
          'role': 'technician',
          'date': '2026-03-06T14:00:00',
          'text':
              'The duplex unit has been repaired and tested with a 50-page double-sided job. '
              'Everything is working properly. Closing this ticket.',
        },
      ],
    },
    {
      'id': 'INC-28510',
      'subject': 'Password Reset for SunPlus Financial System',
      'category': 'Access & Accounts',
      'status': 'resolved',
      'priority': 'high',
      'createdDate': '2026-03-18',
      'lastUpdated': '2026-03-18',
      'description':
          'Locked out of the SunPlus financial system after too many failed login attempts. '
          'Need password reset to access Q1 reports before end of day.',
      'assignedTo': 'Kevin R. Patel',
      'messages': [
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-18T07:50:00',
          'text':
              'I am locked out of SunPlus after entering my old password by mistake several times. '
              'I need access urgently to pull Q1 financial data for a report due today.',
        },
        {
          'author': 'Kevin R. Patel',
          'role': 'technician',
          'date': '2026-03-18T08:10:00',
          'text':
              'Account has been unlocked and a temporary password has been sent to your GC email. '
              'Please log in and set a new password immediately. Let me know if you have any issues.',
        },
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-18T08:25:00',
          'text': 'I am back in. New password set. Thanks for the quick turnaround, Kevin.',
        },
      ],
    },
    {
      'id': 'INC-28478',
      'subject': 'Teams Audio Cuts Out During Video Calls',
      'category': 'Email & Collaboration',
      'status': 'open',
      'priority': 'medium',
      'createdDate': '2026-03-16',
      'lastUpdated': '2026-03-17',
      'description':
          'Audio intermittently cuts out during Microsoft Teams video calls. Other participants '
          'report they cannot hear me for 5-10 seconds at a time. Happens both with headset and laptop speakers.',
      'assignedTo': 'Lisa M. Thompson',
      'messages': [
        {
          'author': 'Jonathan D. Mitchell',
          'role': 'requester',
          'date': '2026-03-16T15:20:00',
          'text':
              'During Teams meetings, my audio drops out for 5-10 seconds at a time. Colleagues say they '
              'cannot hear me. Happens with my Jabra headset and also with the built-in MacBook mic. '
              'Video and screen sharing are unaffected.',
        },
        {
          'author': 'Lisa M. Thompson',
          'role': 'technician',
          'date': '2026-03-17T09:00:00',
          'text':
              'This could be related to the recent Teams update. A few users have reported similar issues. '
              'Can you check if you are on Teams version 24012.x or newer? Also, please try clearing the '
              'Teams cache: quit Teams, delete ~/Library/Application Support/Microsoft/Teams, and relaunch.',
        },
      ],
    },
  ];
}
