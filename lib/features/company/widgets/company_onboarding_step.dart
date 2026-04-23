// =======================================================
// COMPANY ONBOARDING STEP ENUM
// -------------------------------------------------------
// Controla as etapas do fluxo de cadastro da página
// empresarial
// =======================================================

enum CompanyOnboardingStep {
  header,
  identity,
  about,
  hiring,
  jobs,
  team,
  checklist,
}

// =======================================================
// EXTENSÃO PARA NAVEGAÇÃO
// =======================================================

extension CompanyOnboardingStepExtension on CompanyOnboardingStep {
  // ===================================================
  // PRÓXIMO STEP
  // ===================================================
  CompanyOnboardingStep next() {
    final steps = CompanyOnboardingStep.values;
    final nextIndex = index + 1;

    if (nextIndex >= steps.length) {
      return this;
    }

    return steps[nextIndex];
  }

  // ===================================================
  // STEP ANTERIOR
  // ===================================================
  CompanyOnboardingStep previous() {
    final prevIndex = index - 1;

    if (prevIndex < 0) {
      return this;
    }

    return CompanyOnboardingStep.values[prevIndex];
  }

  // ===================================================
  // SE É O ÚLTIMO STEP
  // ===================================================
  bool get isLast {
    return index == CompanyOnboardingStep.values.length - 1;
  }

  // ===================================================
  // SE É O PRIMEIRO STEP
  // ===================================================
  bool get isFirst {
    return index == 0;
  }
}