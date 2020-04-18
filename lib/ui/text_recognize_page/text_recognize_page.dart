import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kanji_dictionary/bloc/text_recognize_bloc.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/utils/string_extension.dart';
import '../components/kanji_list_view.dart';
import '../components/kanji_grid_view.dart';
import '../components/furigana_text.dart';

class TextRecognizePage extends StatefulWidget {
  final ImageSource imageSource;

  TextRecognizePage({this.imageSource}) : assert(imageSource != null);

  @override
  _TextRecognizePageState createState() => _TextRecognizePageState();
}

class _TextRecognizePageState extends State<TextRecognizePage> {
  final scrollController = ScrollController();
  String text = "";
  List<Kanji> kanjis = [];
  bool didChooseImage = false, showShadow = false, showGrid = false;
  ImageSource imageSource;

  Future getImage() async {
    if (imageSource == null) return;

    var image = await ImagePicker.pickImage(source: imageSource, imageQuality: 85);

    if (image == null) {
      return;
    }

    setState(() {
      textRecognizeBloc.reset();
      didChooseImage = true;
    });

    var bytes = await image.readAsBytes();
    var base64Str = base64Encode(bytes);

    textRecognizeBloc.extractTextFromImage(base64Str);
  }

  Future<ImageSource> getImageSource() {
    return showCupertinoModalPopup<ImageSource>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              message: Text("Choose an image to detect kanji from"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text('Camera', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text('Gallery', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                ),
              ],
            )).then((value) => value ?? null);
  }

  @override
  void initState() {
    imageSource = widget.imageSource;
    getImage();

    super.initState();

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          didChooseImage
              ? StreamBuilder(
                  stream: textRecognizeBloc.text,
                  builder: (_, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      text = snapshot.data;
                      if (text.isEmpty) {
                        return Container();
                      }

                      kanjis = text.getKanjis().map((str) => kanjiBloc.allKanjisMap[str]).toList();

                      if (kanjis.isEmpty) {
                        return Container();
                      }

                      return IconButton(
                        icon: AnimatedCrossFade(
                          firstChild: Icon(
                            Icons.view_headline,
                            color: Colors.white,
                          ),
                          secondChild: Icon(
                            Icons.view_comfy,
                            color: Colors.white,
                          ),
                          crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: Duration(milliseconds: 200),
                        ),
                        onPressed: () {
                          setState(() {
                            showGrid = !showGrid;
                          });
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              : Container()
        ],
        title: FuriganaText(
          text: '画像漢字認識',
          tokens: [
            Token(text: '画像', furigana: 'がぞう'),
            Token(text: '漢字', furigana: 'かんじ'),
            Token(text: '認識', furigana: 'にんしき'),
          ],
          style: TextStyle(fontSize: 18),
        ),
        elevation: showShadow ? 8 : 0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: didChooseImage
          ? StreamBuilder(
              stream: textRecognizeBloc.text,
              builder: (_, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  text = snapshot.data;
                  if (text.isEmpty) {
                    return Center(child: Text("No kanji was found in the image.", style: TextStyle(color: Colors.white70)));
                  }

                  kanjis = text.getKanjis().map((str) => kanjiBloc.allKanjisMap[str]).toList();

                  if (kanjis.isEmpty) {
                    return Center(child: Text("No kanji was found in the image.", style: TextStyle(color: Colors.white70)));
                  }

                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        Text(
                          text,
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8, left: 20),
                            child: Text(
                              "Found ${kanjis.length} kanji in the image:",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        showGrid
                            ? KanjiGridView(kanjis: kanjis, scrollPhysics: NeverScrollableScrollPhysics())
                            : KanjiListView(kanjis: kanjis, scrollPhysics: NeverScrollableScrollPhysics())
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          : Center(
              child: Text(
              "Choose an image first.",
              style: TextStyle(color: Colors.white70),
            )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getImageSource().then((val) {
          if (val != null) {
            imageSource = val;
            getImage();
          }
        }),
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}