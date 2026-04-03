// =======================================================
// ONBOARDING STEP ENUM
// -------------------------------------------------------
// Controla as etapas do fluxo de onboarding
// =======================================================

enum OnboardingStep {
  name,
  birthDate,
  specialty,
  languages,
}

// =======================================================
// EXTENSÃO PARA NAVEGAÇÃO
// =======================================================

extension OnboardingStepExtension on OnboardingStep {

  // ===================================================
  // PRÓXIMO STEP
  // ===================================================
  OnboardingStep next() {
    final steps = OnboardingStep.values;
    final nextIndex = index + 1;

    if (nextIndex >= steps.length) {
      return this; // 👈 permanece no último
    }

    return steps[nextIndex];
  }

  // ===================================================
  // STEP ANTERIOR
  // ===================================================
  OnboardingStep previous() {
    final prevIndex = index - 1;

    if (prevIndex < 0) {
      return this; // 👈 permanece no primeiro
    }

    return OnboardingStep.values[prevIndex];
  }

  // ===================================================
  // SE É O ÚLTIMO STEP
  // ===================================================
  bool get isLast {
    return index == OnboardingStep.values.length - 1;
  }

  // ===================================================
  // SE É O PRIMEIRO STEP
  // ===================================================
  bool get isFirst {
    return index == 0;
  }
}