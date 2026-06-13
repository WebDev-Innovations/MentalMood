import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class EmotionSeletionWidget extends StatefulWidget {
  final ValueChanged<EmozioneData> onEmozioneSelected;
  final List<EmozioneData> emozioni;
  final EmozioneData? emozioneSelected;

  const EmotionSeletionWidget({super.key, required this.emozioni, required this.onEmozioneSelected, this.emozioneSelected});

  @override
  State<EmotionSeletionWidget> createState() => _EmotionSeletionWidgetState();
}

class _EmotionSeletionWidgetState extends State<EmotionSeletionWidget> {
  @override
  Widget build(BuildContext context) {
    return listEmozioniUI(widget.emozioni, widget.emozioneSelected);
  }

  Widget listEmozioniUI(List<EmozioneData> listEmozioni, EmozioneData? emozioneSelected) {
    print('Building lista con ${listEmozioni.length} emozioni');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: listEmozioni.length,
      itemBuilder: (context, index) {
        EmozioneData emozione = listEmozioni[index];
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 6.7),
          color: emozioneSelected == emozione ? Colors.red[200] : null,
          shape: emozioneSelected == emozione
              ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.red, width: 2),
          )
              : null,
          child: ListTile(
            title: Text(
              emozione.nome,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            onTap: () async {
              widget.onEmozioneSelected(emozione);
            },
          ),
        );
      },
    );
  }
}
