# Rabbit's Fantasy

## Português — PT-BR

Rabbit's Fantasy é um RPG de ação 2D top-down com estética geométrica inspirada em Tangram.

O projeto está sendo desenvolvido em Godot, com foco inicial na criação de uma demo jogável.

### Estado atual

Atualmente o projeto já possui:

- Personagem controlável com WASD e setas
- Caminhada em quatro direções
- Animação simples de caminhada com alternância de passos
- Corrida com Shift
- Troca automática de sprites conforme a direção
- Câmera acompanhando o jogador
- Colisões no pátio de treinamento
- Cenários iniciais para:
  - Pátio / Castelo
  - Cidade de Aequora
  - Floresta
  - Caverna

### Estrutura do projeto

```text
res://
├── assets/
│   ├── characters/
│   └── maps/
├── scenes/
│   ├── characters/
│   ├── enemies/
│   ├── levels/
│   └── ui/
├── scripts/
├── shaders/
├── systems/
└── temp_gdd/
```

### Personagem principal

O protagonista é um coelho cinza com:

- Espada
- Arco
- Cachecol azul
- Túnica verde
- Bolsa lateral

Atualmente existem sprites para quatro direções cardinais:

- Front
- Back
- Left
- Right

Também estão sendo criados frames adicionais para animação de caminhada.

### Próximos passos

- Finalizar ajustes de colisão no pátio
- Revisar sprites do protagonista
- Avaliar sprites diagonais
- Criar sistema de interação com objetos
- Implementar ataque básico
- Criar tutorial jogável
- Adicionar NPCs iniciais
- Implementar progressão da primeira missão

### Engine

Godot 4.7.x

### Status

Projeto em desenvolvimento.

---

## English — US-EN

Rabbit's Fantasy is a 2D top-down action RPG with a geometric visual style inspired by Tangram shapes.

The project is being developed in Godot, with the initial goal of creating a playable demo.

### Current status

The project currently includes:

- Player movement using WASD and arrow keys
- Four-direction movement
- Simple walking animation using alternating step frames
- Running with Shift
- Automatic directional sprite switching
- Camera following the player
- Collision setup in the training courtyard
- Initial environments for:
  - Courtyard / Castle
  - Aequora City
  - Forest
  - Cave

### Project structure

```text
res://
├── assets/
│   ├── characters/
│   └── maps/
├── scenes/
│   ├── characters/
│   ├── enemies/
│   ├── levels/
│   └── ui/
├── scripts/
├── shaders/
├── systems/
└── temp_gdd/
```

### Main character

The protagonist is a gray rabbit equipped with:

- Sword
- Bow
- Blue scarf
- Green tunic
- Side pouch

The current character sprite set includes four cardinal directions:

- Front
- Back
- Left
- Right

Additional walking animation frames are also being created.

### Next steps

- Finish collision adjustments in the courtyard
- Review the protagonist sprites
- Evaluate diagonal movement sprites
- Create an object interaction system
- Implement basic sword combat
- Build the playable tutorial
- Add the initial NPCs
- Implement progression for the first quest

### Engine

Godot 4.7.x

### Status

Work in progress.