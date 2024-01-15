import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:monami/views/message/model/convo.dart';

class ConvoView extends StatelessWidget {
  const ConvoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(8, 0, 8, 10),
        child: Column(
          children: [
            
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.pink.shade900,
                  ),
                  SizedBox(
                    width: 200,
                    child: ListTile(
                      dense: true,
                      title: Text(
                        "Inositol",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "Online",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Gap(30),
                  Icon(
                    Icons.call,
                    color: Colors.pink.shade900,
                    size: 35,
                  )
                ],
              ),
            ),
            Expanded(child: DocumentScreen(document: Document())),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.pink.shade900,
        ),
        margin: const EdgeInsets.only(left: 10),
        height: 50,
        child: TextFormField(decoration: const InputDecoration()),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}

class DocumentScreen extends StatelessWidget {
  final Document document;

  const DocumentScreen({
    required this.document,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final (title, :modified) = document.metadata;
    final blocks = document.getBlocks();
    return ListView(
      children: [
        Text(title,
            style: GoogleFonts.roboto(
              color: Colors.pink.shade900,
            )),
        Center(
          child: Text(modified,
              style: GoogleFonts.roboto(
                color: Colors.purple.shade900,
              )),
        ),
        ...List.generate(
            blocks.length, (index) => BlockWidget(block: blocks[index]))
      ],
    );
  }
}

class BlockWidget extends StatelessWidget {
  final Block block;

  const BlockWidget({
    required this.block,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle;
    switch (block.type) {
      case 's':
        textStyle = GoogleFonts.roboto(
          color: Colors.purple.shade900,
        );
      case 'r' || 'checkbox':
        textStyle = GoogleFonts.roboto(
          color: Colors.pink.shade900,
        );
      case _:
        textStyle = Theme.of(context).textTheme.bodySmall;
    }

    return Container(
      alignment:
          block.type == "s" ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.all(8),
      child: Text(
        block.text,
        style: textStyle,
      ),
    );
  }
}
