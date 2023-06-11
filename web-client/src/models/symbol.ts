import { SourceLocation } from "./source_location";

export type Symbol = NamespaceSymbol | TypeInferenceSymbol;

export interface NamespaceSymbol {
  identifier: string;
  source_locations: SourceLocation[];
  kind: "namespace";
  fully_qualified_name: string;
}

export interface TypeInferenceSymbol {
  identifier: string;
  source_locations: SourceLocation[];
  kind: "type_inference";
  related_symbol_identifier: string;
}
