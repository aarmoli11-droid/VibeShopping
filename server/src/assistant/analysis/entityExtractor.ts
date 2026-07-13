import { ExtractedEntities, emptyEntities } from '../types/extractedEntities';

const KNOWN_CATEGORIES: ReadonlyArray<{ slug: string; patterns: RegExp[] }> = [
  { slug: 'abarrotes', patterns: [/\b(abarrotes|granos|arroz|frijoles|lentejas|pasta|harina|aceite|az[uú]car|sal|especias)\b/i] },
  { slug: 'lacteos', patterns: [/\b(l[aá]cteos|leche|queso|yogur|mantequilla|crema|huevos|natilla)\b/i] },
  { slug: 'carnes', patterns: [/\b(carnes?|carne\s*de\s*(res|cerdo|pollo)|pollo|pescado|cerdo|res|costillas|chuletas?)\b/i] },
  { slug: 'frutas', patterns: [/\b(frutas?|verduras?|vegetales?|manzanas?|bananos?|pl[aá]tanos?|naranjas?|uvas?|fresas?|br[oó]coli|lechuga|tomates?|cebollas?|zanahorias?)\b/i] },
  { slug: 'bebidas', patterns: [/\b(bebidas?|gaseosas?|jugos?|refrescos?|agua\s*(mineral|purificada)?|cervezas?|vino|gaseosa)\b/i] },
  { slug: 'panaderia', patterns: [/\b(panader[ií]a|pan|panes?|tortillas?|galletas?|reposter[ií]a|pastel|bizcocho)\b/i] },
  { slug: 'congelados', patterns: [/\b(congelados?|helados?|vegetales?\s*congelados|comida\s*congelada|hielo)\b/i] },
  { slug: 'higiene', patterns: [/\b(higiene|jab[oó]n|shampoo|champ[uú]|pasta\s*dental|desodorante|papel\s*higi[ée]nico)\b/i] },
  { slug: 'enlatados', patterns: [/\b(enlatados?|conservas?|at[uú]n|sardinas?|latas?\s*de)\b/i] },
];

export class EntityExtractor {
  private readonly _productPatterns: RegExp[] = [
    /\b(arroz|frijoles?|lentejas|pasta|harina|az[uú]car|sal|aceite)\b/i,
    /\b(leche|queso|yogur|mantequilla|huevos?|natilla|crema)\b/i,
    /\b(carne|pollo|pescado|cerdo|res|costillas?|chuletas?|salchichas?)\b/i,
    /\b(manzanas?|bananos?|pl[aá]tanos?|naranjas?|uvas?|fresas?|limones?)\b/i,
    /\b(pan|panes?|tortillas?|galletas?|pastel|bizcocho)\b/i,
    /\b(cebollas?|zanahorias?|br[oó]coli|tomates?|lechuga|chiles?|ayote|papas?)\b/i,
    /\b(jab[oó]n|shampoo|champ[uú]|desodorante|pasta\s*dental|papel\s*higi[ée]nico)\b/i,
    /\b(gaseosas?|jugos?|refrescos?|cervezas?|vino|agua)\b/i,
    /\b(at[uú]n|sardinas?|conservas?)\b/i,
    /\b(helados?|vegetales?\s*congelados)\b/i,
  ];

  private readonly _storePatterns: Array<{ name: string; patterns: RegExp[] }> = [
    { name: 'Buen Día', patterns: [/\bbuen\s*d[ií]a\b/i] },
    { name: 'Más Súper', patterns: [/\bm[aá]s\s*s[uú]per\b/i] },
    { name: 'Súper Ahorro', patterns: [/\bs[uú]per\s*ahorro\b/i] },
    { name: 'Maxi Palí', patterns: [/\bmaxi\s*pal[ií]\b/i] },
    { name: 'Walmart', patterns: [/\bwalmart\b/i] },
    { name: 'CoopeAgri', patterns: [/\bcoope\s*agri\b/i] },
    { name: 'Super Vida Saludable', patterns: [/\bsuper\s*vida\s*saludable\b/i] },
  ];

  private readonly _unitPattern = /\b(\d+[.,]?\d*)\s*(kg|kilo|kilos|g|gr|gramos?|lb|libras?|oz|l|lt|litros?|ml|unidades?|piezas?)\b/i;
  private readonly _servingsPattern = /\b(para|para\s*unas?)\s*(\d+)\s*(personas?|porciones?|comensales?)\b/i;
  private readonly _budgetPattern = /₡\s*(\d+[.,]?\d*)/;
  private readonly _budgetTextPattern = /\b(\d+[.,]?\d*)\s*(colones|₡|rojos?|tejas?)\b/i;
  private readonly _priceRangePattern = /\b(entre|de)\s*(\d+[.,]?\d*)\s*(y|a)\s*(\d+[.,]?\d*)/i;
  private readonly _priceMaxPattern = /\b(menos\s*de|m[aá]ximo|hasta|m[aá]x)\s*(\d+[.,]?\d*)\b/i;
  private readonly _priceMinPattern = /\b(m[aá]s\s*de|m[ií]nimo|m[ií]n|desde)\s*(\d+[.,]?\d*)\b/i;
  private readonly _brandPattern = /\bmarca\s+(\w+)/i;
  private readonly _dietaryPatterns: Array<{ restriction: string; patterns: RegExp[] }> = [
    { restriction: 'sin gluten', patterns: [/\bsin\s*gluten\b/i] },
    { restriction: 'vegano', patterns: [/\bvegan[ao]\b/i] },
    { restriction: 'vegetariano', patterns: [/\bvegetarian[ao]\b/i] },
    { restriction: 'bajo en calorías', patterns: [/\bbajo\s*en\s*calor[ií]as\b/i] },
    { restriction: 'sin lactosa', patterns: [/\bsin\s*lactosa\b/i] },
    { restriction: 'sin azúcar', patterns: [/\bsin\s*az[uú]car\b/i] },
    { restriction: 'bajo en sodio', patterns: [/\bbajo\s*en\s*sodio\b/i] },
    { restriction: 'diabético', patterns: [/\bdiab[ée]tico\b/i] },
    { restriction: 'orgánico', patterns: [/\borg[aá]nico\b/i] },
    { restriction: 'keto', patterns: [/\bketo\b/i] },
  ];

  extract(question: string): ExtractedEntities {
    const entities = emptyEntities();
    const normalized = question.trim().toLowerCase();

    this._extractProducts(normalized, entities);
    this._extractStores(normalized, entities);
    this._extractCategories(normalized, entities);
    this._extractBudget(normalized, entities);
    this._extractServings(normalized, entities);
    this._extractQuantity(normalized, entities);
    this._extractPriceRange(normalized, entities);
    this._extractBrand(normalized, entities);
    this._extractDietary(normalized, entities);

    if (entities.products.length > 0) {
      entities.product = entities.products[0];
    }

    if (entities.stores.length > 0) {
      entities.store = entities.stores[0];
    }

    if (entities.categories.length > 0) {
      entities.category = entities.categories[0];
    }

    return entities;
  }

  private _extractProducts(text: string, entities: ExtractedEntities): void {
    const seen = new Set<string>();
    const listSeparator = /(?:y|,)\s*/gi;

    const triggerMatch = text.match(
      /(?:quiero|busco|necesito|comprar|venden|encuentro|consigo|tiene)\s+(.+?)(?:\.|$|para|en\s|con\s|sin\s|de\s)/i
    );

    const candidates: string[] = [];

    if (triggerMatch) {
      const remainder = triggerMatch[1].toLowerCase();
      const parts = remainder.split(listSeparator);
      for (const part of parts) {
        const trimmed = part.trim();
        if (trimmed.length > 1) {
          candidates.push(trimmed);
        }
      }
    }

    for (const pattern of this._productPatterns) {
      let match: RegExpExecArray | null;
      const re = new RegExp(pattern.source, 'gi');
      while ((match = re.exec(text)) !== null) {
        const word = match[1] ?? match[0];
        const normalized = word.toLowerCase().trim();
        if (!seen.has(normalized) && normalized.length > 1) {
          seen.add(normalized);
          const singular = normalized.replace(/s$/, '');
          entities.products.push(singular);
        }
      }
    }

    const productListPattern = /(?:y|,)\s*(\w[\wáéíóúÁÉÍÓÚ]+)/gi;
    let listMatch: RegExpExecArray | null;
    while ((listMatch = productListPattern.exec(text)) !== null) {
      const word = listMatch[1].toLowerCase().trim();
      if (word.length > 2 && !seen.has(word)) {
        const isProductWord = this._productPatterns.some(p => p.test(word));
        if (isProductWord) {
          seen.add(word);
          entities.products.push(word);
        }
      }
    }
  }

  private _extractStores(text: string, entities: ExtractedEntities): void {
    for (const store of this._storePatterns) {
      for (const pattern of store.patterns) {
        if (pattern.test(text)) {
          if (!entities.stores.includes(store.name)) {
            entities.stores.push(store.name);
          }
          break;
        }
      }
    }
  }

  private _extractCategories(text: string, entities: ExtractedEntities): void {
    for (const cat of KNOWN_CATEGORIES) {
      for (const pattern of cat.patterns) {
        if (pattern.test(text)) {
          if (!entities.categories.includes(cat.slug)) {
            entities.categories.push(cat.slug);
          }
          break;
        }
      }
    }
  }

  private _extractBudget(text: string, entities: ExtractedEntities): void {
    let match = text.match(this._budgetPattern);
    if (match) {
      entities.budget = this._parseNumber(match[1]);
      return;
    }

    match = text.match(this._budgetTextPattern);
    if (match) {
      entities.budget = this._parseNumber(match[1]);
      return;
    }

    const colonesMatch = text.match(/\b(\d+[.,]?\d*)\s*(colones)\b/i);
    if (colonesMatch) {
      entities.budget = this._parseNumber(colonesMatch[1]);
    }
  }

  private _extractServings(text: string, entities: ExtractedEntities): void {
    const match = text.match(this._servingsPattern);
    if (match) {
      entities.servings = parseInt(match[2], 10);
    }
  }

  private _extractQuantity(text: string, entities: ExtractedEntities): void {
    const match = text.match(this._unitPattern);
    if (match) {
      entities.quantity = this._parseNumber(match[1]);
      entities.unit = this._normalizeUnit(match[2]);
    }
  }

  private _extractPriceRange(text: string, entities: ExtractedEntities): void {
    const rangeMatch = text.match(this._priceRangePattern);
    if (rangeMatch) {
      entities.priceMin = this._parseNumber(rangeMatch[2]);
      entities.priceMax = this._parseNumber(rangeMatch[4]);
      return;
    }

    const maxMatch = text.match(this._priceMaxPattern);
    if (maxMatch) {
      entities.priceMax = this._parseNumber(maxMatch[2]);
    }

    const minMatch = text.match(this._priceMinPattern);
    if (minMatch) {
      entities.priceMin = this._parseNumber(minMatch[2]);
    }
  }

  private _extractBrand(text: string, entities: ExtractedEntities): void {
    const match = text.match(this._brandPattern);
    if (match) {
      entities.brand = match[1].toLowerCase();
    }

    const knownBrands = /\b(dos\s*pinos|brianna|sardimar|tosh|pochteca|natura|del\s*valle|coca[- ]?cola|pepsi|lays|marinela)\b/i;
    const brandMatch = text.match(knownBrands);
    if (brandMatch) {
      entities.brand = brandMatch[1].toLowerCase().replace(/\s+/g, ' ');
    }
  }

  private _extractDietary(text: string, entities: ExtractedEntities): void {
    for (const rule of this._dietaryPatterns) {
      for (const pattern of rule.patterns) {
        if (pattern.test(text)) {
          if (!entities.dietaryRestrictions.includes(rule.restriction)) {
            entities.dietaryRestrictions.push(rule.restriction);
          }
          break;
        }
      }
    }

    const healthyMatch = text.match(/(?:quiero|necesito|busco)\s*(?:algo\s*)?(?:m[aá]s\s*)?(saludable|nutritivo|natural)\b/i);
    if (healthyMatch) {
      if (!entities.dietaryRestrictions.includes('saludable')) {
        entities.dietaryRestrictions.push('saludable');
      }
    }
  }

  private _parseNumber(raw: string): number {
    const cleaned = raw.replace(',', '.').replace(/[^\d.]/g, '');
    const num = parseFloat(cleaned);
    return isNaN(num) ? 0 : num;
  }

  private _normalizeUnit(raw: string): string {
    const lower = raw.toLowerCase();
    if (/^(kg|kilo|kilos)$/i.test(lower)) return 'kg';
    if (/^(g|gr|gramos?)$/i.test(lower)) return 'g';
    if (/^(lb|libras?)$/i.test(lower)) return 'lb';
    if (/^(oz)$/i.test(lower)) return 'oz';
    if (/^(l|lt|litros?)$/i.test(lower)) return 'l';
    if (/^(ml)$/i.test(lower)) return 'ml';
    if (/^unidades?$/i.test(lower)) return 'unidades';
    if (/^piezas?$/i.test(lower)) return 'piezas';
    return raw;
  }
}
