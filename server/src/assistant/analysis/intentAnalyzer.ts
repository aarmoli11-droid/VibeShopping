import { Intent } from '../types/analyzedQuery';

interface IntentRule {
  intent: Intent;
  patterns: RegExp[];
  weight: number;
}

export interface IntentResult {
  intent: Intent;
  confidence: number;
}

export class IntentAnalyzer {
  private readonly _rules: IntentRule[] = [
    {
      intent: 'comparePrices',
      patterns: [
        /\bmás\s*barato\b/i,
        /\bmás\s*caro\b/i,
        /\bcomparar\b/i,
        /\bcomparación\b/i,
        /\bcuál\s*es\s*más\b/i,
        /\bprecios\s*más\b/i,
        /\bdónde\s*es\s*más\b/i,
        /\bqu[ée]\s*tienda\b.*\bmejor\b/i,
        /\bcuál\s*conviene\s*más\b/i,
      ],
      weight: 0.90,
    },
    {
      intent: 'recipe',
      patterns: [
        /\breceta\b/i,
        /\bcómo\s*preparar\b/i,
        /\bcómo\s*hacer\b/i,
        /\bcocinar\b/i,
        /\bpreparar\b.*\bcon\b/i,
        /\bingredientes\s*para\b/i,
        /\bcómo\s*cocinar\b/i,
      ],
      weight: 0.90,
    },
    {
      intent: 'shoppingList',
      patterns: [
        /\blista\s*de\s*compras?\b/i,
        /\blista\s*del\s*s[uú]per\b/i,
        /\bqu[ée]\s*necesito\b.*\bcomprar\b/i,
        /\blista\b.*\bmercado\b/i,
        /\bhazme?\s*una\s*lista\b/i,
        /\bhaz\s*una\s*lista\b/i,
      ],
      weight: 0.90,
    },
    {
      intent: 'weeklyPlan',
      patterns: [
        /\bplan\s*semanal\b/i,
        /\bmen[uú]\s*semanal\b/i,
        /\bcomidas?\s*de\s*la\s*semana\b/i,
        /\bplan\s*de\s*comidas?\b/i,
        /\borganiza\s*mi\s*semana\b/i,
        /\bcomidas?\s*para\s*la\s*semana\b/i,
      ],
      weight: 0.92,
    },
    {
      intent: 'budget',
      patterns: [
        /\bpresupuesto\b/i,
        /\bgastar\b/i,
        /\bahorrar\b/i,
        /\bcu[aá]nto\s*cuesta\b/i,
        /\bcu[aá]nto\s*gast[ae]r\b/i,
        /₡\s*\d+/,
        /\bcon\s+\d+[.,]?\d*\s*(colones|₡)\b/i,
        /\bno\s*gastar\s*m[aá]s\s*de\b/i,
      ],
      weight: 0.85,
    },
    {
      intent: 'substitution',
      patterns: [
        /\bsustituto\b/i,
        /\balternativa\b/i,
        /\breemplazar\b/i,
        /\ben\s*lugar\s*de\b/i,
        /\bcambiar\s*por\b/i,
        /\bopci[oó]n\s*sin\b/i,
        /\ben\s*vez\s*de\b/i,
        /\balgo\s*parecido\b/i,
      ],
      weight: 0.88,
    },
    {
      intent: 'nutrition',
      patterns: [
        /\b(nutrici[oó]n|nutritivo)\b/i,
        /\bcalor[ií]as?\b/i,
        /\bprote[ií]na\b/i,
        /\bsaludable\b/i,
        /\bvitaminas?\b/i,
        /\bdieta\b/i,
        /\balimentaci[oó]n\s*saludable\b/i,
        /\binformaci[oó]n\s*nutricional\b/i,
        /\bvalor\s*nutricional\b/i,
      ],
      weight: 0.88,
    },
    {
      intent: 'storeRecommendation',
      patterns: [
        /\bd[oó]nde\s*comprar\b/i,
        /\ben\s*qu[ée]\s*(tienda|supermercado)\b/i,
        /\b(mejor\s+)?tienda\b/i,
        /\bsupermercado\b/i,
        /\bcerca\s*de\b/i,
        /\bd[oó]nde\s*venden\b/i,
        /\bcu[aá]l\s*(tienda|super)\b/i,
      ],
      weight: 0.80,
    },
    {
      intent: 'recommendation',
      patterns: [
        /\brecomienda\b/i,
        /\bsugiere\b/i,
        /\brecomendaci[oó]n\b/i,
        /\bqu[ée]\s*me\s*recomiendas\b/i,
        /\bcu[aá]l\s*es\s*mejor\b/i,
        /\bmejor\s*opci[oó]n\b/i,
        /\bcu[aá]l\s*(me\s+)?recomiendas\b/i,
        /\bsugerencia\b/i,
      ],
      weight: 0.87,
    },
    {
      intent: 'generalQuestion',
      patterns: [
        /^(hola|buenas|saludos|hey)\b/i,
        /^qu[ée]\s*haces\b/i,
        /^qui[ée]n\s*eres\b/i,
        /^c[oó]mo\s*funciona\b/i,
        /^qu[ée]\s*puedes?\s*hacer\b/i,
        /^ayuda\b/i,
        /^comandos\b/i,
      ],
      weight: 0.95,
    },
    {
      intent: 'searchProduct',
      patterns: [
        /\bquiero\b/i,
        /\bbusco\b/i,
        /\bnecesito\b/i,
        /\bd[oó]nde\s*encuentro\b/i,
        /\bconsigo\b/i,
        /\bvenden\b/i,
        /\bcomprar\b/i,
        /\btiene\s*.*\ben\s*.*\b/i,
      ],
      weight: 0.75,
    },
  ];

  analyze(text: string): IntentResult {
    const normalized = text.trim().toLowerCase();

    if (normalized.length === 0) {
      return { intent: 'unknown', confidence: 0.30 };
    }

    const matches: Array<{ intent: Intent; count: number; maxWeight: number }> = [];

    for (const rule of this._rules) {
      let count = 0;
      for (const pattern of rule.patterns) {
        if (pattern.test(normalized)) {
          count++;
        }
      }
      if (count > 0) {
        matches.push({
          intent: rule.intent,
          count,
          maxWeight: rule.weight,
        });
      }
    }

    if (matches.length === 0) {
      return { intent: 'unknown', confidence: 0.30 };
    }

    matches.sort((a, b) => {
      if (a.count !== b.count) return b.count - a.count;
      return b.maxWeight - a.maxWeight;
    });

    const best = matches[0];
    let confidence = best.maxWeight;

    if (best.count >= 2) {
      confidence = Math.min(best.maxWeight + 0.05, 0.96);
    }

    if (matches.length >= 2 && matches[0].intent === 'searchProduct') {
      const second = matches[1];
      if (second.maxWeight > 0.80) {
        return { intent: second.intent, confidence: second.maxWeight + 0.04 };
      }
    }

    return { intent: best.intent, confidence };
  }
}
