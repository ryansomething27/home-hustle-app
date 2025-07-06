import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/bank_provider.dart';
import '../../data/models/user.dart';
import '../../core/theme.dart';
import '../../core/helpers.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _addressController = TextEditingController();
  Map<String, Map<String, dynamic>> childSettings = {};
  bool showDollars = true;
  String homeAddress = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: Load from API/provider
    // Mock data for now
    setState(() {
      homeAddress = '123 Main Street, Anytown, USA';
      _addressController.text = homeAddress;
      showDollars = true;
      childSettings = {
        'child1': {
          'name': 'Sarah',
          'radius': 5,
          'publicJobsEnabled': true,
          'storeEnabled': true,
          'investmentEnabled': false,
          'loanEnabled': false,
        },
        'child2': {
          'name': 'Michael',
          'radius': 3,
          'publicJobsEnabled': false,
          'storeEnabled': true,
          'investmentEnabled': false,
          'loanEnabled': false,
        },
      };
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user?.role != UserRole.parent) {
      return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: Center(
          child: Text(
            'Access Denied',
            style: TextStyle(color: AppTheme.cream),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: Text(
          'Family Settings',
          style: TextStyle(
            color: AppTheme.cream,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.cream),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildCurrencySettings(),
            const SizedBox(height: 24),
            _buildLocationSettings(),
            const SizedBox(height: 24),
            _buildChildrenSettings(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cream.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GENERAL',
            style: TextStyle(
              color: AppTheme.cream.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Family Name',
              style: TextStyle(
                color: AppTheme.cream,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'The Johnson Family',
              style: TextStyle(
                color: AppTheme.cream.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.edit,
              color: AppTheme.cream.withOpacity(0.5),
              size: 20,
            ),
            onTap: () => _showEditFamilyNameDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cream.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENCY DISPLAY',
            style: TextStyle(
              color: AppTheme.cream.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyOption(
                  'Dollars',
                  '\$',
                  showDollars,
                  () => setState(() => showDollars = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCurrencyOption(
                  'Stars',
                  '⭐',
                  !showDollars,
                  () => setState(() => showDollars = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Children will see all values in ${showDollars ? 'dollars' : 'stars'}',
            style: TextStyle(
              color: AppTheme.cream.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(
    String label,
    String symbol,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cream.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.cream : AppTheme.cream.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.cream,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cream.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LOCATION',
            style: TextStyle(
              color: AppTheme.cream.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            style: TextStyle(color: AppTheme.cream),
            decoration: InputDecoration(
              labelText: 'Home Address',
              labelStyle: TextStyle(color: AppTheme.cream.withOpacity(0.6)),
              hintText: 'Enter your home address',
              hintStyle: TextStyle(color: AppTheme.cream.withOpacity(0.4)),
              suffixIcon: Icon(
                Icons.location_on,
                color: AppTheme.cream.withOpacity(0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.cream.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.cream),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Used to calculate distances for public jobs',
            style: TextStyle(
              color: AppTheme.cream.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'CHILDREN SETTINGS',
            style: TextStyle(
              color: AppTheme.cream.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...childSettings.entries.map((entry) => _buildChildSettingsCard(
          entry.key,
          entry.value,
        )),
      ],
    );
  }

  Widget _buildChildSettingsCard(String childId, Map<String, dynamic> settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cream.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.cream,
                child: Text(
                  settings['name'].substring(0, 1),
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                settings['name'],
                style: TextStyle(
                  color: AppTheme.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRadiusSlider(childId, settings['radius']),
          const SizedBox(height: 16),
          _buildFeatureToggles(childId, settings),
        ],
      ),
    );
  }

  Widget _buildRadiusSlider(String childId, int radius) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Public Job Radius',
              style: TextStyle(
                color: AppTheme.cream,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$radius miles',
              style: TextStyle(
                color: AppTheme.cream.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.cream,
            inactiveTrackColor: AppTheme.cream.withOpacity(0.3),
            thumbColor: AppTheme.cream,
            overlayColor: AppTheme.cream.withOpacity(0.2),
          ),
          child: Slider(
            value: radius.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                childSettings[childId]!['radius'] = value.toInt();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureToggles(String childId, Map<String, dynamic> settings) {
    return Column(
      children: [
        _buildFeatureToggle(
          'Public Jobs',
          'Can apply for neighborhood jobs',
          settings['publicJobsEnabled'],
          (value) => setState(() {
            childSettings[childId]!['publicJobsEnabled'] = value;
          }),
        ),
        const SizedBox(height: 12),
        _buildFeatureToggle(
          'Family Store',
          'Can purchase from family store',
          settings['storeEnabled'],
          (value) => setState(() {
            childSettings[childId]!['storeEnabled'] = value;
          }),
        ),
        const SizedBox(height: 12),
        _buildFeatureToggle(
          'Investment Account',
          'Access to investment features',
          settings['investmentEnabled'],
          (value) => setState(() {
            childSettings[childId]!['investmentEnabled'] = value;
          }),
        ),
        const SizedBox(height: 12),
        _buildFeatureToggle(
          'Loans',
          'Can request loans',
          settings['loanEnabled'],
          (value) => setState(() {
            childSettings[childId]!['loanEnabled'] = value;
          }),
        ),
      ],
    );
  }

  Widget _buildFeatureToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.cream,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.cream.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.cream,
          activeTrackColor: AppTheme.cream.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveSettings,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.cream,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Save Settings',
        style: TextStyle(
          color: AppTheme.primaryDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showEditFamilyNameDialog() {
    final controller = TextEditingController(text: 'The Johnson Family');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: Text(
          'Edit Family Name',
          style: TextStyle(color: AppTheme.cream),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppTheme.cream),
          decoration: InputDecoration(
            hintText: 'Enter family name',
            hintStyle: TextStyle(color: AppTheme.cream.withOpacity(0.4)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.cream.withOpacity(0.3)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.cream),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.cream.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save family name
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(color: AppTheme.cream),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement save to API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}