import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masked_text_formatter/masked_text_formatter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _Demo {
  final MaskedTextFormatter formatter;
  final TextInputType keyboardType;
  final String hint;
  TextEditingController textController;

  _Demo(
      {@required this.formatter,
      @required this.hint,
      @required this.keyboardType,
      String text}) {
    textController = TextEditingController(text: formatter.formatMask(text));
  }
}

class _MainPageState extends State<MainPage> {
  final List<_Demo> demos = [
    _Demo(
        formatter: MaskedTextFormatter.simple(formatStyle: "344"),
        hint: "130 1234 5678",
        keyboardType: TextInputType.phone,
        text: "13012345678"),
    _Demo(
        formatter: MaskedTextFormatter.complex(
            formatStyle: "+86 *** **** ****", mark: "*"),
        hint: "+86 130 1234 5678",
        keyboardType: TextInputType.phone,
        text: "13012345678"),
    _Demo(
        formatter: MaskedTextFormatter.mask(
            formatStyle: "000 0000 0000", emptyPlaceholder: "_"),
        hint: "130 1234 5678",
        keyboardType: TextInputType.phone,
        text: "13012345678"),
    _Demo(
        formatter: MaskedTextFormatter.custom(
            formatStyle: "000 000 0000 0000 000X",
            emptyPlaceholder: "_",
            filterRules: {"X": RegExp(r'[0-9Xx]'), "0": RegExp(r'[0-9]')},
            escapeMark: "\\"),
        hint: "510 010 2020 0101 000X",
        keyboardType: TextInputType.text,
        text: "51001020200101000X"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Formatter Demo'),
        ),
        body: SafeArea(
            child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          itemBuilder: (context, index) {
            return _buildTextField(demos[index]);
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 12,
              color: Colors.transparent,
            );
          },
          itemCount: demos.length,
        )));
  }

  Widget _buildTextField(_Demo demo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: [
          TextFormField(
              controller: demo.textController,
              inputFormatters: [demo.formatter],
              autocorrect: false,
              keyboardType: demo.keyboardType,
              autovalidateMode: AutovalidateMode.always,
              maxLines: 1,
              decoration: InputDecoration(
                  hintText: demo.hint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen)),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)))),
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
                width: 48,
                height: 48,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child:
                          const Icon(Icons.clear, color: Colors.grey, size: 24),
                      onTap: () {
                        demo.textController.clear();
                        demo.formatter.clear();
                      }),
                )),
          )
        ],
      ),
    );
  }
}
