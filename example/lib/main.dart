import 'package:date_util/date_util.dart';
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
  List<_Demo> demos;

  @override
  void initState() {
    super.initState();
    demos = [
      _Demo(
          formatter: MaskedTextFormatter.simple("344"),
          hint: "130 1234 5678",
          keyboardType: TextInputType.phone,
          text: "13012345678"),
      _Demo(
          formatter: MaskedTextFormatter.complex("😊😊😊****😊😊😊",
              mark: "*", deleteEndPlaceholder: false),
          hint: "😊😊😊----😊😊😊",
          keyboardType: TextInputType.phone,
          text: "12345"),
      _Demo(
          formatter:
              MaskedTextFormatter.mask("000 0000 0000", emptyPlaceholder: "_"),
          hint: "130 1234 5678",
          keyboardType: TextInputType.phone,
          text: "13012345678"),
      _Demo(
          formatter: MaskedTextFormatter.custom("000 000 0000 0000 000X",
              emptyPlaceholder: "_",
              filterRules: {
                "X": RegExpMatcher.from(r'[0-9Xx]'),
                "0": RegExpMatcher.from(r'[0-9]')
              }),
          hint: "510 010 2020 0101 000X",
          keyboardType: TextInputType.text,
          text: "51001020200101000X"),
      _Demo(
          formatter: MaskedTextFormatter.custom("2YYY/MM/DD",
              emptyPlaceholder: "_",
              filterRules: {
                "Y": CustomDateMatcher("Y"),
                "M": CustomDateMatcher("M"),
                "D": CustomDateMatcher("D"),
                "2": RegExpMatcher.from(r'[12]'),
              },
              escapeMark: "\\"),
          hint: "请输入年月日，必须小于等于当前日期",
          keyboardType: TextInputType.phone,
          text: ""),
    ];
  }

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

  @override
  void dispose() {
    super.dispose();
    this.demos?.clear();
  }
}

class CustomDateMatcher extends Matcher {
  static final sDate = DateTime.now();
  static final sDateUtility = DateUtil();

  final String mask;

  CustomDateMatcher(this.mask);

  @override
  bool hasMatch(String previousText, String value) {
    if (SpanText.isDigit(value)) {
      if (mask == "Y") {
        if (previousText.startsWith("1")) {
          return true;
        } else {
          if (previousText.length == 1) {
            return sDate.year >=
                int.parse(previousText + value + "00", radix: 10);
          } else if (previousText.length == 2) {
            return sDate.year >=
                int.parse(previousText + value + "0", radix: 10);
          } else {
            return sDate.year >= int.parse(previousText + value, radix: 10);
          }
        }
      } else if (mask == "M") {
        final year = int.parse(previousText.substring(0, 4), radix: 10);
        var month;
        if (previousText.length == 5) {
          month = int.parse(value + "0", radix: 10);
        } else {
          month = int.parse(
              previousText.substring(previousText.length - 1) + value,
              radix: 10);
        }
        if (sDate.year == year) {
          return sDate.month >= month;
        } else {
          return 12 >= month;
        }
      } else {
        final year = int.parse(previousText.substring(0, 4), radix: 10);
        final month = int.parse(previousText.substring(5, 7), radix: 10);
        var day;
        if (previousText.length == 8) {
          day = int.parse(value + "0", radix: 10);
        } else {
          day = int.parse(
              previousText.substring(previousText.length - 1) + value,
              radix: 10);
        }
        if (sDate.year == year && sDate.month == month) {
          return sDate.day >= day;
        } else {
          final days = sDateUtility.daysInMonth(month, year);
          return days >= day;
        }
      }
    } else {
      return false;
    }
  }
}
