class Node {
  final String id;
  String title;
  bool titleUnedited;
  Children? children;
  List<int> path;

  List<Node> get childNodes => children?.attached ?? [];

  Node({
    required this.id,
    required this.title,
    required this.path,
    this.titleUnedited = false,
    this.children,
  });

  factory Node.fromJson(Map<String, dynamic> json, {required List<int> path}) {
    return Node(
      path: path,
      id: json['id'] as String,
      title: json['title'] as String,
      titleUnedited: json['titleUnedited'] as bool? ?? false,
      children: json['children'] == null
          ? null
          : Children.fromJson(
              json['children'] as Map<String, dynamic>,
              parentPath: path,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleUnedited': titleUnedited,
      if (children != null) 'children': children!.toJson(),
    };
  }
}

class Children {
  final List<Node> attached;

  Children({required this.attached});

  factory Children.fromJson(
    Map<String, dynamic> json, {
    required List<int> parentPath,
  }) {
    final attachedMaps = json['attached'] as List;
    return Children(
      attached: List.generate(attachedMaps.length, (index) {
        return Node.fromJson(attachedMaps[index], path: [...parentPath, index]);
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {'attached': attached.map((e) => e.toJson()).toList()};
  }
}

class Xmind {
  final Node root;

  Xmind({required this.root});

  Xmind.empty() : root = Node(id: 'root', title: '中心节点', path: []);

  factory Xmind.fromJson(List<dynamic> json) {
    return Xmind(
      root: Node.fromJson(
        json[0]['rootTopic'] as Map<String, dynamic>,
        path: [],
      ),
    );
  }

  List<dynamic> toJson() {
    return [
      {'rootTopic': root.toJson()},
    ];
  }
}
