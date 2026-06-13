import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class MotivationSeletionWidget extends StatelessWidget {
  final ValueChanged<MotivazioneData> onMotivazioneSelected;
  final List<MotivazioneData> motivazioni;
  final List<MotivazioneData?> motivazioniSelected;

  const MotivationSeletionWidget({super.key, required this.motivazioni, required this.onMotivazioneSelected, required this.motivazioniSelected});

  @override
  Widget build(BuildContext context) {
    return listMotivazioniUI(motivazioni,motivazioniSelected);
  }

  Widget listMotivazioniUI(List<MotivazioneData> listMotivazioni, List<MotivazioneData?> motivazioniSelected) {
    print('Building lista con ${listMotivazioni.length} motivazioni');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: listMotivazioni.length,
      itemBuilder: (context, index) {
        MotivazioneData motivazione = listMotivazioni[index];
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 6.7),
          color: motivazioniSelected.contains(motivazione) ? Colors.yellow[200] : null,
          shape: motivazioniSelected.contains(motivazione)
              ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.orange, width: 2),
          )
              : null,
          child: ListTile(
            title: Text(
              motivazione.testo,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            onTap: () async {
              onMotivazioneSelected(motivazione);
            },
          ),
        );
      },
    );
  }
}
