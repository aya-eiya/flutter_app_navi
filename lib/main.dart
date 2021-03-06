import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Navi Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String title = 'page 1';

  void _changeTitle(String title) {
    setState(() {
      this.title = title;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Navigator(
          observers: <NavigatorObserver>[_PageNaviObserver(_changeTitle)],
          onGenerateRoute: (RouteSettings settings) =>
              _PageRouteBuilder.createRoute(() => const _Page1())));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class _PageNaviObserver extends NavigatorObserver {
  _PageNaviObserver(this.changeTitle) : super();
  final void Function(String) changeTitle;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    // previousRoute が null のときは _MainPageState を初期化中のため
    // setState でエラーを起こすので changeTitle を実行しない
    if (previousRoute != null && route.settings?.name != null) {
      changeTitle(route.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute.settings?.name != null) {
      changeTitle(previousRoute.settings.name);
    }
  }
}

mixin _Page implements Widget {
  String get title;
}

class _Page1 extends StatelessWidget with _Page {
  const _Page1({Key key}) : super(key: key);

  @override
  String get title => 'page 1';

  @override
  Widget build(BuildContext context) {
    const _Page nextPage = _Page2();
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('this is page 1'),
        RaisedButton(
          onPressed: () {
            Navigator.of(context)
                .push(_PageRouteBuilder.createRoute(() => nextPage));
          },
          child: const Text('Page 2'),
        )
      ],
    ));
  }
}

class _Page2 extends StatelessWidget with _Page {
  const _Page2({
    Key key,
  }) : super(key: key);

  @override
  String get title => 'page 2';

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('this is page 2'),
        RaisedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Page 1'),
        )
      ],
    ));
  }
}

abstract class _PageRouteBuilder {
  static MaterialPageRoute<_Page> createRoute(_Page Function() builder) {
    final _Page page = builder();
    return MaterialPageRoute<_Page>(
        builder: (_) => page,
        settings: RouteSettings(name: page.title, arguments: page));
  }
}
