import 'package:flutter/material.dart';
import 'package:invoid/mainPage.dart';
import 'package:invoid/streamPage.dart';

class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _theme.primaryColor,
        title: Text(
          'Select one mode',
          style: _theme.textTheme.headline2,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlatButton(
              color: _theme.buttonColor,
              child: Text(
                'Detect Face',
                style: _theme.textTheme.headline2,
              ),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MainPage())),
            ),
            FlatButton(
              color: _theme.buttonColor,
              child: Text(
                'Image Stream',
                style: _theme.textTheme.headline2,
              ),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StreamPage())),
            )
          ],
        ),
      ),
    );
  }
}
