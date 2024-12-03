import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:lottie/lottie.dart';
import 'dart:html' if (dart.library.html) 'dart:html';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数学题目',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProblemListPage(),
    );
  }
}

class ProblemListPage extends StatefulWidget {
  const ProblemListPage({super.key});

  @override
  State<ProblemListPage> createState() => _ProblemListPageState();
}

class _ProblemListPageState extends State<ProblemListPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<dynamic> problems = [];
  Map<String, dynamic>? selectedProblem;

  @override
  void initState() {
    super.initState();
    loadProblems();
  }

  Future<void> loadProblems() async {
    try {
      print('开始加载 JSON 文件...');
      final String response = await rootBundle.loadString('assets/math.json');
      final data = await json.decode(response);
      setState(() {
        problems = data['problems'];
      });
    } catch (e, stackTrace) {
      print('Error loading JSON: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> importJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = result.files.first;
        final content = utf8.decode(file.bytes!);
        final data = json.decode(content);
        setState(() {
          problems = data['problems'];
          selectedProblem = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导入成功！')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    }
  }

  Future<void> exportJson() async {
    try {
      final content = json.encode({'problems': problems});
      final blob = Blob([content], 'application/json');
      final url = Url.createObjectUrlFromBlob(blob);
      final anchor = AnchorElement(href: url)
        ..setAttribute('download', 'math_problems.json')
        ..click();
      Url.revokeObjectUrl(url);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导出成功！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double fontScale = 1.5;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '数学题目列表',
          style: TextStyle(fontSize: 20 * fontScale),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.2, end: 0),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: importJson,
            tooltip: '导入JSON文件',
          )
          .animate()
          .fadeIn(delay: 200.ms)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0)),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: exportJson,
            tooltip: '导出JSON文件',
          )
          .animate()
          .fadeIn(delay: 300.ms)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0)),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: problems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.network(
                      'https://assets10.lottiefiles.com/packages/lf20_qm8eqzse.json',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '加载中...',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedList(
                        key: _listKey,
                        padding: const EdgeInsets.all(8),
                        initialItemCount: problems.length,
                        itemBuilder: (context, index, animation) {
                          final problem = problems[index];
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOut)),
                            ),
                            child: Card(
                              elevation: selectedProblem == problem ? 4 : 1,
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: selectedProblem == problem
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  '第${problem['id']}题',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16 * fontScale,
                                    color: selectedProblem == problem
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        problem['question'],
                                        style: TextStyle(
                                          fontSize: 14 * fontScale,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 16),
                                    Text(
                                      '解题思路:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14 * fontScale,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    ...List<Widget>.from(
                                      problem['approach'].map(
                                        (step) => Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            step,
                                            style: TextStyle(
                                              fontSize: 14 * fontScale,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedProblem = problem;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // 右侧详情面板
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: selectedProblem == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.touch_app,
                                      size: 48,
                                      color: Colors.grey[400],
                                    )
                                    .animate(onPlay: (controller) => controller.repeat())
                                    .shake(duration: 2000.ms),
                                    const SizedBox(height: 16),
                                    Text(
                                      '请选择一道题目',
                                      style: TextStyle(
                                        fontSize: 16 * fontScale,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '第${selectedProblem!['id']}题: ${selectedProblem!['question']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18 * fontScale,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn()
                                    .slideX(),
                                    const SizedBox(height: 32),
                                    buildSolutionSteps(context, fontScale)
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .slideX(),
                                    const SizedBox(height: 32),
                                    buildAnswer(context, fontScale)
                                    .animate()
                                    .fadeIn(delay: 400.ms)
                                    .slideX(),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildSolutionSteps(BuildContext context, double fontScale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                '解题步骤:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * fontScale,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List<Widget>.from(
            selectedProblem!['solution']['steps'].map(
              (step) => Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Text(
                  step,
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnswer(BuildContext context, double fontScale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                '答案:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * fontScale,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selectedProblem!['solution']['answer'],
            style: TextStyle(
              color: Colors.red,
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
