import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker/data/sample_entries.dart';
import 'package:mood_tracker/main.dart';
import 'package:mood_tracker/models/mood_entry.dart';
import 'package:mood_tracker/widgets/mood_card.dart';
import 'package:mood_tracker/widgets/mood_score_selector.dart';

// Widget tests for mood entry form validation and saving behavior.

/// Renders the app in a window tall enough for every card to be built.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MoodTrackerApp());
}

Finder get saveButton => find.widgetWithText(FilledButton, 'Save entry');

void main() {
  testWidgets('saving without a score shows an error and adds no entry', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Choose a score from 1 to 10'), findsOneWidget);
    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length));
  });

  testWidgets(
    'a note over the maximum length shows an error and is not saved',
    (tester) async {
      await pumpApp(tester);
      final note = List.filled(maxNoteLength + 1, 'a').join();

      await tester.tap(find.widgetWithText(ChoiceChip, '7'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), note);
      await tester.tap(saveButton);
      await tester.pump();

      expect(
        find.text('Note must be $maxNoteLength characters or fewer.'),
        findsOneWidget,
      );
      expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        note,
      );
      expect(
        tester
            .widget<MoodScoreSelector>(find.byType(MoodScoreSelector))
            .selectedScore,
        7,
      );
    },
  );

  testWidgets('saving an entry puts it at the top of the history', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Rainy walk home');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('Rainy walk home'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a maximum-length note is saved and the form clears', (
    tester,
  ) async {
    await pumpApp(tester);
    final note = List.filled(maxNoteLength, 'a').join();

    await tester.tap(find.widgetWithText(ChoiceChip, '7'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), note);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text(note),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester
          .widget<MoodScoreSelector>(find.byType(MoodScoreSelector))
          .selectedScore,
      isNull,
    );
  });

  testWidgets('an empty note is saved as no note and the form clears', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '5'));
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('No note'),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester
          .widget<MoodScoreSelector>(find.byType(MoodScoreSelector))
          .selectedScore,
      isNull,
    );
  });
}
