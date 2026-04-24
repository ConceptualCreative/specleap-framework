#!/usr/bin/env python3
"""
SpecLeap — Renderizador de CONTRATO.md
Convierte respuestas planas (project.name) a estructura anidada y renderiza con Jinja2
"""

import json
import sys
from datetime import datetime
from jinja2 import Environment, FileSystemLoader
import re

def flatten_to_nested(flat_dict):
    """
    Convierte dict plano {'project.name': 'foo'} a anidado {'project': {'name': 'foo'}}
    """
    nested = {}
    
    for key, value in flat_dict.items():
        parts = key.split('.')
        current = nested
        
        for i, part in enumerate(parts):
            if i == len(parts) - 1:
                # Último nivel, asignar valor
                current[part] = value
            else:
                # Crear nivel intermedio si no existe
                if part not in current:
                    current[part] = {}
                current = current[part]
    
    return nested

def convert_string_to_type(value, expected_type):
    """
    Convierte strings a su tipo apropiado (bool, int, array)
    """
    if expected_type == 'boolean':
        if isinstance(value, bool):
            return value
        return value.lower() in ['true', '1', 'yes', 's', 'si']
    
    if expected_type == 'number':
        try:
            return int(value)
        except:
            return 0
    
    if expected_type == 'array':
        if isinstance(value, list):
            return value
        # Si es string vacío, devolver array vacío
        if value == "":
            return []
        # Si es JSON array string
        if isinstance(value, str) and value.startswith('['):
            try:
                return json.loads(value)
            except:
                return []
        return [value]
    
    return value

def normalize_answers(answers_flat, questions_meta):
    """
    Normaliza respuestas según metadata de preguntas (tipos, defaults)
    """
    normalized = {}
    
    for q in questions_meta:
        q_id = q['id']
        q_type = q['type']
        q_default = q.get('default', None)
        
        # Obtener valor o usar default
        value = answers_flat.get(q_id, q_default)
        
        # Convertir a tipo apropiado
        if value is not None:
            value = convert_string_to_type(value, q_type)
        
        normalized[q_id] = value
    
    return normalized

def add_computed_fields(nested_dict):
    """
    Agrega campos computados (fecha actual, contadores, etc.)
    """
    # Agregar fecha actual si no existe
    if 'project' in nested_dict:
        if not nested_dict['project'].get('created_at'):
            nested_dict['project']['created_at'] = datetime.now().strftime('%Y-%m-%d')
        
        if not nested_dict['project'].get('status'):
            nested_dict['project']['status'] = 'draft'
        
        if not nested_dict['project'].get('version'):
            nested_dict['project']['version'] = '1.0'
    
    # Contar features
    if 'features' in nested_dict and 'core' in nested_dict['features']:
        core_count = len(nested_dict['features']['core']) if nested_dict['features']['core'] else 0
        nested_dict['_computed'] = {'core_count': core_count}
    
    return nested_dict

def main():
    if len(sys.argv) < 4:
        print("Uso: render-contrato.py <answers.json> <questions.json> <template.md> [output.md]")
        sys.exit(1)
    
    answers_file = sys.argv[1]
    questions_file = sys.argv[2]
    template_file = sys.argv[3]
    output_file = sys.argv[4] if len(sys.argv) > 4 else None
    
    # Leer archivos
    with open(answers_file, 'r') as f:
        answers_flat = json.load(f)
    
    with open(questions_file, 'r') as f:
        questions_data = json.load(f)
        questions_meta = questions_data['questions']
    
    # Normalizar respuestas según tipos
    answers_normalized = normalize_answers(answers_flat, questions_meta)
    
    # Convertir plano a anidado
    answers_nested = flatten_to_nested(answers_normalized)
    
    # Agregar campos computados
    answers_nested = add_computed_fields(answers_nested)
    
    # Configurar Jinja2
    template_dir = '/'.join(template_file.split('/')[:-1])
    template_name = template_file.split('/')[-1]
    
    env = Environment(
        loader=FileSystemLoader(template_dir),
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True
    )
    
    # Leer template (separar YAML frontmatter del contenido Jinja2)
    with open(template_file, 'r') as f:
        template_content = f.read()
    
    # Convertir placeholders tipo {VAR} a sintaxis Jinja2 {{ var }} para templates legacy
    # Solo si no es el template principal (que ya usa Jinja2)
    if 'LEGACY' in template_file or '{PROJECT_NAME}' in template_content:
        import re
        # Convertir {VAR_NAME} -> {{ var_name }}
        def convert_placeholder(match):
            var_name = match.group(1).lower().replace('_', '.')
            return '{{ ' + var_name + ' }}'
        template_content = re.sub(r'\{([A-Z_]+)\}', convert_placeholder, template_content)
    
    # Detectar frontmatter YAML
    if template_content.startswith('---'):
        parts = template_content.split('---', 2)
        if len(parts) >= 3:
            yaml_front = parts[1]
            jinja_content = parts[2]
        else:
            yaml_front = ""
            jinja_content = template_content
    else:
        yaml_front = ""
        jinja_content = template_content
    
    # Renderizar YAML frontmatter
    yaml_template = env.from_string(yaml_front)
    yaml_rendered = yaml_template.render(**answers_nested)
    
    # Renderizar contenido Jinja2
    content_template = env.from_string(jinja_content)
    content_rendered = content_template.render(**answers_nested)
    
    # Combinar
    final_output = f"---\n{yaml_rendered}---{content_rendered}"
    
    # Escribir output
    if output_file:
        with open(output_file, 'w') as f:
            f.write(final_output)
        print(f"✅ CONTRATO.md generado: {output_file}")
    else:
        print(final_output)

if __name__ == '__main__':
    main()
