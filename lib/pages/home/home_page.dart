import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showModal() {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Pesquisar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchCtrl.text = '';
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _searchCtrl.text.length > 4,
                child: Text('Resultados para: ${_searchCtrl.text}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('GeoRef'),
          actions: [
            IconButton(
              onPressed: _showModal,
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              AppBar(
                toolbarHeight: 150,
                title: const Text(
                  'GeoRef App',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.green,
              ),
              const ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.logout),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.amber,
        body: Image.asset(
          'assets/images/fake_map.png',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      );
}
