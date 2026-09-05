import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SwingPlusApp());
}

class SwingPlusApp extends StatelessWidget {
  const SwingPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swing Plus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> dividendHistory = [
    {'stock': 'ITC', 'date': '28 Aug 2026', 'dps': '₹ 7.50', 'qty': '135', 'total': '₹ 1,012.50', 'type': 'Final Dividend'},
    {'stock': 'POWERGRID', 'date': '14 Aug 2026', 'dps': '₹ 4.25', 'qty': '72', 'total': '₹ 306.00', 'type': 'Interim Dividend'},
    {'stock': 'HDFCBANK', 'date': '10 Jul 2026', 'dps': '₹ 19.50', 'qty': '47', 'total': '₹ 916.50', 'type': 'Annual Dividend'},
    {'stock': 'RELIANCE', 'date': '19 Jun 2026', 'dps': '₹ 10.00', 'qty': '11', 'total': '₹ 110.00', 'type': 'Final Dividend'},
    {'stock': 'RADICO', 'date': '02 May 2026', 'dps': '₹ 3.00', 'qty': '16', 'total': '₹ 48.00', 'type': 'Final Dividend'},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile ? _buildMobileLayout() : _buildTabletLayout();
  }

  // 📱 Mobile Layout
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTabTitle(_selectedIndex), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
      ),
      body: _buildSelectedScreen(false),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF00E676),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Core'),
          BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: 'Liquor'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'ETFs'),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Dividends'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Importer'),
        ],
      ),
    );
  }

  // 📊 Tablet Layout
  Widget _buildTabletLayout() {
    final isTabletLandscape = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: isTabletLandscape
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.selected,
            backgroundColor: const Color(0xFF1A1A1A),
            selectedIconTheme: const IconThemeData(color: Color(0xFF00E676)),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Overview')),
              NavigationRailDestination(icon: Icon(Icons.star), label: Text('Core')),
              NavigationRailDestination(icon: Icon(Icons.local_bar), label: Text('Liquor')),
              NavigationRailDestination(icon: Icon(Icons.show_chart), label: Text('ETFs & Growth')),
              NavigationRailDestination(icon: Icon(Icons.payments), label: Text('Dividends')),
              NavigationRailDestination(icon: Icon(Icons.upload_file), label: Text('Importer')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(_getTabTitle(_selectedIndex), style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: const Color(0xFF121212),
              ),
              body: _buildSelectedScreen(isTabletLandscape),
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0: return 'Swing Plus • Dashboard Overview';
      case 1: return 'Core Bluechip Holdings';
      case 2: return 'Liquor Satellite Portfolio';
      case 3: return 'Index ETFs & High-Growth Plays';
      case 4: return 'Dividends Income Ledger';
      case 5: return 'Importer';
      default: return 'Swing Plus';
    }
  }

  Widget _buildSelectedScreen(bool isLandscape) {
    switch (_selectedIndex) {
      case 0: return _buildOverviewTab(isLandscape);
      case 1: return _buildPositionGrid([
          {'name': 'RELIANCE', 'qty': '11', 'buy': '1291.70', 'pnl': '+4.2%'},
          {'name': 'TRENT', 'qty': '8', 'buy': '2727.50', 'pnl': '+8.5%'},
        ], isLandscape);
      case 2: return _buildPositionGrid([
          {'name': 'RADICO', 'qty': '16', 'buy': '3967.00', 'pnl': '+12.4%'},
        ], isLandscape);
      case 3: return _buildPositionGrid([
          {'name': 'ZOMATO', 'qty': '83', 'buy': '250.59', 'pnl': '+28.4%'},
        ], isLandscape);
      case 4: return _buildDividendTab(isLandscape);
      case 5: return _buildImporterTab();
      default: return const SizedBox.shrink();
    }
  }

  // 📂 Importer Tab
  Widget _buildImporterTab() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.upload_file),
        label: const Text("Upload Broker File"),
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['csv', 'xlsx'],
          );
          if (result != null) {
            final file = result.files.single;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Imported: ${file.name}")),
            );
          }
        },
      ),
    );
  }

  // 🌐 Fetch Live Price Example
  Future<double> fetchStockPrice(String symbol) async {
    final url = Uri.parse("https://query1.finance.yahoo.com/v7/finance/quote?symbols=$symbol");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['quoteResponse']['result'][0]['regularMarketPrice'];
    } else {
      throw Exception("Failed to fetch price");
    }
  }

  // Overview Tab placeholder
  Widget _buildOverviewTab(bool isLandscape) {
    return const Center(child: Text("Overview Dashboard Coming Soon"));
  }

  // Dividend Tab placeholder
  Widget _buildDividendTab(bool isLandscape) {
    return const Center(child: Text("Dividend Ledger Coming Soon"));
  }

  // ✅ Corrected Position Grid
  Widget _buildPositionGrid(List<Map<String, String>> items, bool isLandscape) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isPositive = item['pnl']!.startsWith('+');
        return Card(
          child: ListTile(
            title: Text(
              item['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Qty: ${item['qty']} | Avg: ₹${item['buy']}"),
            trailing: Text(
              item['pnl']!,
              style: TextStyle(
                color: isPositive ? const Color(0xFF00E676) : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
