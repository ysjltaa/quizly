import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RaceQuestion {
  final String text;
  final List<String> options;
  final int answer;
  const RaceQuestion(this.text, this.options, this.answer);
}

/// Sementara masih soal contoh. Nanti diganti soal asli per subject.
List<RaceQuestion> demoQuestions(String subject) => const [
  RaceQuestion('Which Flutter widget can change its state?',
      ['StatelessWidget', 'StatefulWidget', 'Container', 'Text'], 1),
  RaceQuestion('Which language does Flutter use?',
      ['Kotlin', 'Swift', 'Dart', 'Java'], 2),
  RaceQuestion('Which SQL command retrieves data?',
      ['INSERT', 'SELECT', 'DROP', 'ALTER'], 1),
  RaceQuestion('How many bits are in 1 byte?', ['4', '8', '16', '32'], 1),
  RaceQuestion('What does CPU stand for?', [
    'Central Process Unit',
    'Central Processing Unit',
    'Computer Power Unit',
    'Core Processing Utility'
  ], 1),
];

/// Ringkasan hasil race, dikirim lewat onFinished (untuk history).
class RaceSummary {
  final String subject, rival;
  final int myScore, rivalScore, correct, total;
  final bool forfeited;
  const RaceSummary({
    required this.subject,
    required this.rival,
    required this.myScore,
    required this.rivalScore,
    required this.correct,
    required this.total,
    required this.forfeited,
  });
  bool get won => !forfeited && myScore > rivalScore;
  bool get draw => !forfeited && myScore == rivalScore;
}

class RaceScreen extends StatefulWidget {
  const RaceScreen({
    super.key,
    required this.code,
    required this.subject,
    required this.me,
    required this.rival,
    required this.questions,
    this.onFinished,
  });
  final String code, subject, me, rival;
  final List<RaceQuestion> questions;
  final void Function(RaceSummary summary)? onFinished;

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  static const total = 30;
  int idx = 0, timeLeft = total, myScore = 0, rivalScore = 0, rivalDone = 0;
  int correct = 0;
  int? picked;
  bool finished = false, forfeited = false, _reported = false;
  Timer? _tick, _rivalTimer;
  final _rnd = Random();

  int get n => widget.questions.length;
  bool get _isOver => forfeited || (finished && rivalDone >= n);
  int _points(int left) => 100 + (left / total * 50).round();

  @override
  void initState() {
    super.initState();
    _startQuestion();
    _rivalLoop(); // SIMULASI lawan. Ganti dengan stream dari backend.
  }

  void _startQuestion() {
    picked = null;
    timeLeft = total;
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) _answer(-1);
    });
  }

  void _rivalLoop() {
    final secs = 4 + _rnd.nextInt(18);
    _rivalTimer = Timer(Duration(seconds: secs), () {
      if (!mounted || forfeited) return;
      setState(() {
        if (_rnd.nextDouble() < .7) rivalScore += _points(total - secs);
        rivalDone++;
      });
      _report();
      if (rivalDone < n) _rivalLoop();
    });
  }

  void _answer(int i) {
    if (picked != null || forfeited) return;
    _tick?.cancel();
    setState(() {
      picked = i;
      if (i == widget.questions[idx].answer) {
        myScore += _points(timeLeft);
        correct++;
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted || forfeited) return;
      if (idx + 1 >= n) {
        setState(() => finished = true);
        _report();
      } else {
        setState(() => idx++);
        _startQuestion();
      }
    });
  }

  /// Kirim ringkasan sekali saja, setelah race benar-benar selesai.
  void _report() {
    if (_reported || !_isOver) return;
    _reported = true;
    widget.onFinished?.call(RaceSummary(
      subject: widget.subject,
      rival: widget.rival,
      myScore: myScore,
      rivalScore: rivalScore,
      correct: correct,
      total: n,
      forfeited: forfeited,
    ));
  }

  Future<void> _onLeave() async {
    if (_isOver) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave the race?'),
        content: Text('If you leave now, ${widget.rival} wins automatically.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Leave')),
        ],
      ),
    );
    if (leave == true && mounted) {
      _tick?.cancel();
      _rivalTimer?.cancel();
      setState(() => forfeited = true);
      _report();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _rivalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.subject} · ${widget.code}'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Leave race',
              icon: const Icon(Icons.exit_to_app_rounded),
              onPressed: _onLeave,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _scoreBar(widget.me, myScore, finished ? n : idx, Colors.blue),
            const SizedBox(height: 8),
            _scoreBar(widget.rival, rivalScore, rivalDone, Colors.orange),
            const SizedBox(height: 16),
            Expanded(
              child: forfeited
                  ? _forfeitView()
                  : finished
                  ? _result()
                  : _question(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _scoreBar(String name, int score, int done, Color c) => Row(children: [
    SizedBox(
        width: 80,
        child: Text(name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600))),
    Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
            value: done / n, minHeight: 12, color: c),
      ),
    ),
    const SizedBox(width: 10),
    SizedBox(
        width: 48,
        child: Text('$score',
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700))),
  ]);

  Widget _question() {
    final q = widget.questions[idx];
    return ListView(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Question ${idx + 1}/$n'),
        Chip(
          avatar: const Icon(Icons.timer_rounded, size: 18),
          label: Text('${timeLeft}s'),
        ),
      ]),
      LinearProgressIndicator(value: timeLeft / total),
      const SizedBox(height: 20),
      Text(q.text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      for (int i = 0; i < q.options.length; i++) _option(q, i),
    ]);
  }

  Widget _option(RaceQuestion q, int i) {
    Color? bg;
    if (picked != null) {
      if (i == q.answer) {
        bg = Colors.green.shade100;
      } else if (i == picked) {
        bg = Colors.red.shade100;
      }
    }
    return Card(
      elevation: 0,
      color: bg,
      child: ListTile(
        title: Text(q.options[i]),
        onTap: picked == null ? () => _answer(i) : null,
      ),
    );
  }

  Widget _forfeitView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.flag_rounded, size: 80, color: Colors.redAccent),
      const SizedBox(height: 12),
      const Text('You left the race',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('${widget.rival} wins.'),
      const SizedBox(height: 24),
      FilledButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: const Text('Back to Home')),
    ]),
  );

  Widget _result() {
    if (rivalDone < n) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Waiting for ${widget.rival} to finish ($rivalDone/$n)...'),
          ]));
    }
    final win = myScore > rivalScore;
    final draw = myScore == rivalScore;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(draw ? Icons.handshake_rounded : Icons.emoji_events_rounded,
            size: 90, color: win ? Colors.amber : Colors.grey),
        const SizedBox(height: 12),
        Text(draw ? "It's a draw!" : (win ? 'You Win!' : 'You Lose'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('${widget.me}: $myScore   ·   ${widget.rival}: $rivalScore'),
        const SizedBox(height: 24),
        FilledButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Back to Home')),
      ]),
    );
  }
}