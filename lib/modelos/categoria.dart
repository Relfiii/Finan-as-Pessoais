import 'package:flutter/material.dart';

/// Modelo para categorias de transações
class Category {
  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converte o objeto para Map para armazenamento no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Cria um objeto Category a partir de um Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      color: Color(map['color']),
      icon: IconsCategory.obterIconePorCodigo(map['icon']) ?? IconsCategory.outros,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Cria uma cópia do objeto com novos valores
  Category copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category{id: $id, name: $name, description: $description}';
  }
}

/// Classe com ícones predefinidos para categorias
class IconsCategory {
  static const IconData alimentacao = Icons.restaurant;
  static const IconData transporte = Icons.directions_car;
  static const IconData educacao = Icons.school;
  static const IconData saude = Icons.local_hospital;
  static const IconData lazer = Icons.movie;
  static const IconData vestuario = Icons.shopping_bag;
  static const IconData moradia = Icons.home;
  static const IconData trabalho = Icons.work;
  static const IconData outros = Icons.category;
  
  /// Lista de todos os ícones disponíveis
  static const Map<String, IconData> todosIcones = {
    'alimentacao': alimentacao,
    'transporte': transporte,
    'educacao': educacao,
    'saude': saude,
    'lazer': lazer,
    'vestuario': vestuario,
    'moradia': moradia,
    'trabalho': trabalho,
    'outros': outros,
  };
  
  /// Retorna um ícone por nome ou o padrão se não encontrar
  static IconData obterIcone(String nome) {
    return todosIcones[nome] ?? outros;
  }
  
  /// Retorna um ícone por código (codePoint) ou o padrão se não encontrar
  static IconData? obterIconePorCodigo(int codePoint) {
    // Mapeia os códigos dos ícones predefinidos
    const Map<int, IconData> iconesPorCodigo = {
      0xe56c: alimentacao,  // Icons.restaurant
      0xe531: transporte,   // Icons.directions_car
      0xe80c: educacao,     // Icons.school
      0xe0d0: saude,        // Icons.local_hospital
      0xe02c: lazer,        // Icons.movie
      0xe8cc: vestuario,    // Icons.shopping_bag
      0xe88a: moradia,      // Icons.home
      0xe85d: trabalho,     // Icons.work
      0xe574: outros,       // Icons.category
    };
    
    return iconesPorCodigo[codePoint];
  }
}
