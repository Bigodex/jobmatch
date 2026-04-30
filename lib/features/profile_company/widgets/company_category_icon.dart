// =======================================================
// COMPANY CATEGORY ICON
// -------------------------------------------------------
// Mantém o mesmo mapeamento visual das categorias usadas
// no cadastro da página empresarial.
// =======================================================

import 'package:jobmatch/core/constants/app_icons.dart';

String getCompanyCategoryIcon(String category) {
  switch (category.trim()) {
    case 'Agronegócio':
      return AppIcons.plant;
    case 'Alimentação':
      return AppIcons.feed;
    case 'Automotivo':
      return AppIcons.wheel;
    case 'Beleza e Estética':
      return AppIcons.lipstick;
    case 'Consultoria':
      return AppIcons.laptop;
    case 'Construção Civil':
      return AppIcons.helmet;
    case 'E-commerce':
      return AppIcons.store;
    case 'Educação':
      return AppIcons.cap;
    case 'Energia':
      return AppIcons.ray;
    case 'Entretenimento':
      return AppIcons.popcorn;
    case 'Financeiro':
      return AppIcons.bagmoney;
    case 'Hotelaria':
      return AppIcons.hotel;
    case 'Imobiliário':
      return AppIcons.key;
    case 'Indústria':
      return AppIcons.industry;
    case 'Jurídico':
      return AppIcons.law;
    case 'Logística':
      return AppIcons.boxes;
    case 'Marketing':
      return AppIcons.speaker;
    case 'Moda':
      return AppIcons.hanger;
    case 'Recursos Humanos':
      return AppIcons.rh;
    case 'Saúde':
      return AppIcons.healthy;
    case 'Serviços':
      return AppIcons.service;
    case 'Tecnologia':
      return AppIcons.code;
    case 'Telecomunicações':
      return AppIcons.antenna;
    case 'Turismo':
      return AppIcons.planet;
    case 'Varejo':
      return AppIcons.fastcar;
    default:
      return AppIcons.buildingbriefcase;
  }
}

const List<String> companyCategoryOptions = [
  'Agronegócio',
  'Alimentação',
  'Automotivo',
  'Beleza e Estética',
  'Consultoria',
  'Construção Civil',
  'E-commerce',
  'Educação',
  'Energia',
  'Entretenimento',
  'Financeiro',
  'Hotelaria',
  'Imobiliário',
  'Indústria',
  'Jurídico',
  'Logística',
  'Marketing',
  'Moda',
  'Recursos Humanos',
  'Saúde',
  'Serviços',
  'Tecnologia',
  'Telecomunicações',
  'Turismo',
  'Varejo',
];
