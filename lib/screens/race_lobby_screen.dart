import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quiz_history.dart';
import '../models/subject.dart';
import 'race_screen.dart';

/// 1v1 race lobby (FE only). The rival is simulated.
/// Replace the "SIMULATED" parts with real-time backend data later.
class RaceLobbyScreen extends StatefulWidget {
  const RaceLobbyScreen({super.key, this.myName = 'You'});
  final String myName;

  @override
  State<RaceLobbyScreen> createState() => _RaceLobbyScreenState();
}

class _RaceLobbyScreenState extends State<RaceLobbyScreen> {
  final _codeCtrl = TextEditingController();
  String? code;
  bool isHost = false, rivalJoined = false;
  Subject subject = dummySubjects.first;
  int? countdown;
  Timer? _t;

  String _genCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  void _create() {
    setState(() {
      code = _genCode();
      isHost = true;
      rivalJoined = false;
    });
    // SIMULATED: the rival joins after 2.5 seconds
    _t = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => rivalJoined = true);
    });
  }

  void _join() {
    final c = _codeCtrl.text.trim().toUpperCase();
    if (c.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Code must be 6 characters')));
      return;
    }
    setState(() {
      code = c;
      isHost = false;
      rivalJoined = true; // the host is assumed to be already in the room
    });
  }

  void _saveRace(RaceSummary s) {
    final result = s.forfeited
        ? 'Forfeit'
        : s.draw
        ? 'Draw'
        : s.won
        ? 'Win'
        : 'Lose';
    globalQuizHistory.insert(0, QuizHistory(
      subjectTitle: s.subject,
      score: s.total == 0 ? 0 : (s.correct / s.total * 100).round(),
      correctCount: s.correct,
      totalQuestions: s.total,
      date: DateTime.now(),
      isRace: true,
      rivalName: s.rival,
      raceResult: result,
      raceScore: s.myScore,
    ));
  }

  void _start() {
    setState(() => countdown = 3);
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown! <= 1) {
        t.cancel();
        setState(() => countdown = null);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => RaceScreen(
            code: code!,
            subject: subject.title,
            me: widget.myName,
            rival: 'Rival_42',
            questions: subject.questions
                .map((q) => RaceQuestion(q.questionText, q.options, q.correctIndex))
                .toList(),
            onFinished: _saveRace,
          ),
        ));
      } else {
        setState(() => countdown = countdown! - 1);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Race Mode')),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: code == null ? _entry(cs) : _room(cs),
        ),
        if (countdown != null)
          Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: Text('$countdown',
                style: const TextStyle(
                    fontSize: 120, color: Colors.white, fontWeight: FontWeight.w800)),
          ),
      ]),
    );
  }

  Widget _entry(ColorScheme cs) => ListView(children: [
    Icon(Icons.flag_circle_rounded, size: 80, color: cs.primary),
    const SizedBox(height: 8),
    const Text('Fast and accurate wins!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
    const SizedBox(height: 4),
    Text('Your score depends on both speed and correct answers.',
        textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
    const SizedBox(height: 28),
    FilledButton.icon(
        onPressed: _create,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Room')),
    const SizedBox(height: 24),
    const Row(children: [
      Expanded(child: Divider()),
      Padding(padding: EdgeInsets.all(8), child: Text('or')),
      Expanded(child: Divider()),
    ]),
    const SizedBox(height: 12),
    TextField(
      controller: _codeCtrl,
      maxLength: 6,
      textCapitalization: TextCapitalization.characters,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, letterSpacing: 6),
      decoration: const InputDecoration(hintText: 'CODE', border: OutlineInputBorder()),
    ),
    OutlinedButton.icon(
        onPressed: _join,
        icon: const Icon(Icons.login_rounded),
        label: const Text('Join Room')),
  ]);

  Widget _room(ColorScheme cs) => ListView(children: [
    Card(
      elevation: 0,
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text('Room Code'),
          const SizedBox(height: 4),
          Text(code!,
              style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 8)),
        ]),
      ),
    ),
    const SizedBox(height: 16),
    _player(widget.myName, true, cs),
    _player(rivalJoined ? 'Rival_42' : 'Waiting for opponent...', rivalJoined, cs),
    const SizedBox(height: 16),
    DropdownButtonFormField<Subject>(
      initialValue: subject,
      isExpanded: true,
      decoration: const InputDecoration(
          labelText: 'Quiz subject', border: OutlineInputBorder()),
      items: dummySubjects
          .map((s) => DropdownMenuItem(value: s, child: Text(s.title)))
          .toList(),
      onChanged: isHost ? (v) => setState(() => subject = v!) : null,
    ),
    if (!isHost)
      const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text('The host chooses the subject.', style: TextStyle(fontSize: 12)),
      ),
    const SizedBox(height: 20),
    FilledButton(
      onPressed: rivalJoined ? _start : null,
      child: Text(rivalJoined ? 'Start Race' : 'Waiting for opponent...'),
    ),
  ]);

  Widget _player(String name, bool ready, ColorScheme cs) => Card(
    elevation: 0,
    child: ListTile(
      leading: CircleAvatar(
          backgroundColor: ready ? cs.primary : cs.surfaceContainerHighest,
          child: Icon(ready ? Icons.person : Icons.hourglass_top_rounded,
              color: ready ? cs.onPrimary : cs.onSurfaceVariant)),
      title: Text(name),
      trailing: ready ? const Icon(Icons.check_circle, color: Colors.green) : null,
    ),
  );
}