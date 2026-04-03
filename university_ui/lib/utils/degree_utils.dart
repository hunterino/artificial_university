import 'package:flutter/material.dart';

IconData getDegreeIcon(String degreeId) {
  switch (degreeId) {
    case 'BSCS001': return Icons.computer;
    case 'BSBA001': return Icons.business_center;
    case 'BSHI001': return Icons.health_and_safety;
    case 'BSCY001': return Icons.security;
    case 'BSPM001': return Icons.assignment;
    case 'BAPS001': return Icons.psychology;
    case 'BAEL001': return Icons.menu_book;
    case 'BAGD001': return Icons.games;
    case 'BAED001': return Icons.cast_for_education;
    case 'BADC001': return Icons.campaign;
    case 'BAIS001': return Icons.public;
    case 'BAUX001': return Icons.design_services;
    default: return Icons.school;
  }
}

Color getDegreeColor(String degreeId) {
  switch (degreeId) {
    case 'BSCS001': return Colors.blue;
    case 'BSBA001': return Colors.green;
    case 'BSHI001': return Colors.red;
    case 'BSCY001': return Colors.deepPurple;
    case 'BSPM001': return Colors.orange;
    case 'BAPS001': return Colors.purple;
    case 'BAEL001': return Colors.indigo;
    case 'BAGD001': return Colors.pink;
    case 'BAED001': return Colors.teal;
    case 'BADC001': return Colors.cyan;
    case 'BAIS001': return Colors.amber;
    case 'BAUX001': return Colors.deepOrange;
    default: return Colors.grey;
  }
}
