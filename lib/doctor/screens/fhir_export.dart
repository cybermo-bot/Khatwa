import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/doctor_repository.dart';
import '../data/models.dart';
import '../ui/labels.dart';
import '../ui/style.dart';

/// A small FHIR R4 collection Bundle for one patient: the pseudonymous
/// Patient (id = ref, no name) and one Observation per active finding.
Map<String, dynamic> buildPatientBundle(Patient patient, List<Finding> findings) => {
      'resourceType': 'Bundle',
      'type': 'collection',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'entry': [
        {
          'fullUrl': 'urn:uuid:${patient.id}',
          'resource': {
            'resourceType': 'Patient',
            'id': patient.ref,
            if (patient.sex != null) 'gender': patient.sex == 'F' ? 'female' : 'male',
            if (patient.governorate != null) 'address': [
              {'state': patient.governorate, 'country': 'TN'},
            ],
          },
        },
        for (final f in findings.where((f) => f.isActive))
          {
            'fullUrl': 'urn:uuid:${f.id}',
            'resource': {
              'resourceType': 'Observation',
              'id': f.id,
              'status': f.reviewedBy == null ? 'preliminary' : 'final',
              'code': {'text': kindLabels[f.kind] ?? f.kind},
              'subject': {'reference': 'Patient/${patient.ref}'},
              'effectiveDateTime': f.createdAt.toUtc().toIso8601String(),
              'bodySite': {'text': '${regionLabels[f.region] ?? f.region}, ${sideLabel(f.side).toLowerCase()}'},
              'valueString': statusLabels[f.status] ?? f.status,
              if (f.note.isNotEmpty) 'note': [{'text': f.note}],
            },
          },
      ],
    };

/// Default "Exporter FHIR": shows the Bundle and copies it.
Future<void> showFhirExport(BuildContext context, DoctorRepository repo, Patient patient) async {
  final findings = await repo.findings(patientId: patient.id).first;
  if (!context.mounted) return;
  final json = const JsonEncoder.withIndent('  ').convert(buildPatientBundle(patient, findings));
  final p = DPalette.of(context);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dRadius)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 8, 8),
              child: Row(children: [
                Expanded(child: Text('Bundle FHIR R4 · ${patient.displayName}', style: DText.h2(p))),
                IconButton(
                  tooltip: 'Fermer',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SelectableText(json,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.45, color: p.inkSoft)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: FilledButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copier'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: json));
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
