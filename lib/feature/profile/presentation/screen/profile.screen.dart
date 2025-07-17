import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Student Data
  final String studentName = "Ahmad Rizky Pratama";
  final String studentClass = "XII RPL 1";
  final String studentNisn = "1234567890";
  final String studentNis = "20210001";
  final String studentEmail = "ahmad.rizky@smkn1.sch.id";
  final String studentPhone = "081234567890";
  final String studentAddress = "Jl. Merdeka No. 123, Jakarta Selatan";
  final String waliKelas = "Ibu Siti Aminah, S.Pd";
  final String jurusan = "Rekayasa Perangkat Lunak";
  final String angkatan = "2021";
  
  // Statistics
  final double attendanceRate = 92.5;
  final int totalHadir = 185;
  final int totalTidakHadir = 8;
  final int totalTerlambat = 7;
  final int totalIzin = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildPersonalInfo(),
            const SizedBox(height: 24),
            _buildAcademicInfo(),
            const SizedBox(height: 24),
            _buildAttendanceStats(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildSettings(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D47A1),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Profil Siswa',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.edit),
          onPressed: () {
            // Handle edit profile
          },
          tooltip: 'Edit Profil',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white,
              child: Icon(
                Iconsax.user,
                size: 50,
                color: const Color(0xFF1976D2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Student Name
          Text(
            studentName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Class and NISN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha:0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.user_tag, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '$studentClass • $studentNisn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.personalcard, color: Color(0xFF1976D2), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Pribadi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            icon: Iconsax.card,
            label: 'NIS',
            value: studentNis,
          ),
          _buildInfoItem(
            icon: Iconsax.sms,
            label: 'Email',
            value: studentEmail,
          ),
          _buildInfoItem(
            icon: Iconsax.call,
            label: 'No. Telepon',
            value: studentPhone,
          ),
          _buildInfoItem(
            icon: Iconsax.location,
            label: 'Alamat',
            value: studentAddress,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.teacher, color: Color(0xFF1976D2), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Akademik',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            icon: Iconsax.code,
            label: 'Jurusan',
            value: jurusan,
          ),
          _buildInfoItem(
            icon: Iconsax.calendar_2,
            label: 'Angkatan',
            value: angkatan,
          ),
          _buildInfoItem(
            icon: Iconsax.profile_2user,
            label: 'Wali Kelas',
            value: waliKelas,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.chart_1, color: Color(0xFF1976D2), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistik Kehadiran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Attendance Rate
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tingkat Kehadiran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${attendanceRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: attendanceRate >= 90 ? const Color(0xFF4CAF50) : 
                               attendanceRate >= 75 ? const Color(0xFFFF9800) : 
                               const Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: attendanceRate / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      attendanceRate >= 90 ? const Color(0xFF4CAF50) : 
                      attendanceRate >= 75 ? const Color(0xFFFF9800) : 
                      const Color(0xFFE91E63),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Hadir',
                totalHadir.toString(),
                const Color(0xFF4CAF50),
                Iconsax.tick_circle,
              ),
              _buildStatCard(
                'Tidak Hadir',
                totalTidakHadir.toString(),
                const Color(0xFFE91E63),
                Iconsax.close_circle,
              ),
              _buildStatCard(
                'Terlambat',
                totalTerlambat.toString(),
                const Color(0xFFFF9800),
                Iconsax.timer_1,
              ),
              _buildStatCard(
                'Izin',
                totalIzin.toString(),
                const Color(0xFF9C27B0),
                Iconsax.document_text,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.flash_1, color: Color(0xFF1976D2), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Riwayat Absensi',
                  Iconsax.document_text,
                  const Color(0xFF9C27B0),
                  () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Ubah Password',
                  Iconsax.key,
                  const Color(0xFF00BCD4),
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.setting_2, color: Color(0xFF1976D2), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingItem(
            icon: Iconsax.notification,
            title: 'Notifikasi',
            subtitle: 'Atur notifikasi absensi',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Iconsax.shield_security,
            title: 'Keamanan',
            subtitle: 'Pengaturan keamanan akun',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Iconsax.info_circle,
            title: 'Bantuan',
            subtitle: 'Pusat bantuan dan FAQ',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Iconsax.logout,
            title: 'Keluar',
            subtitle: 'Keluar dari akun',
            onTap: () {},
            isLast: true,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
    bool isDanger = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDanger 
                          ? Colors.red.withValues(alpha:0.1) 
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isDanger ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDanger ? Colors.red : const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 8),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}