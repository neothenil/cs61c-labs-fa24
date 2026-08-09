#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t *state, unsigned int snum);
static char next_square(game_state_t *state, unsigned int snum);
static void update_tail(game_state_t *state, unsigned int snum);
static void update_head(game_state_t *state, unsigned int snum);

const char* const default_board[] = {
  "####################\n",
  "#                  #\n",
  "# d>D    *         #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "#                  #\n",
  "####################\n",
};
const char* out_of_memory = "Program has run out of memory.\n";

/* Task 1 */
game_state_t *create_default_state() {
  game_state_t* state = (game_state_t*)malloc(sizeof(game_state_t));

  // setup board
  state->num_rows = sizeof(default_board) / sizeof(char*);
  // We should have to check the return value of every malloc call.
  // But it complicates the code without using macros or goto statement.
  // So we just ignore it.
  state->board = (char**)malloc(sizeof(default_board));
  for (size_t i = 0; i < state->num_rows; ++i) {
    state->board[i] = (char*)malloc(strlen(default_board[i]) + 1);
    strcpy(state->board[i], default_board[i]);
  }

  // setup snakes
  state->num_snakes = 1;
  state->snakes = (snake_t*)malloc(sizeof(snake_t));
  state->snakes[0].tail_row = 2;
  state->snakes[0].tail_col = 2;
  state->snakes[0].head_row = 2;
  state->snakes[0].head_col = 4;
  state->snakes[0].live = true;

  return state;
}

/* Task 2 */
void free_state(game_state_t *state) {
  if (state == NULL) return;

  free(state->snakes);
  for (size_t i = 0; i < state->num_rows; ++i) {
    free(state->board[i]);
  }
  free(state->board);
  free(state);
}

/* Task 3 */
void print_board(game_state_t *state, FILE *fp) {
  if (state == NULL || fp == NULL) return;
  
  for (size_t i = 0; i < state->num_rows; ++i) {
    fprintf(fp, "%s", state->board[i]);
  }
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t *state, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t *state, unsigned int row, unsigned int col) { return state->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  if (strchr("wasd", c)) {
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  if (strchr("WASDx", c)) {
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  if (strchr("wasd^<v>WASDx", c)) {
    return true;
  }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  switch (c) {
    case '^': return 'w';
    case '<': return 'a';
    case 'v': return 's';
    case '>': return 'd';
  }
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  switch (c) {
    case 'W': return '^';
    case 'A': return '<';
    case 'S': return 'v';
    case 'D': return '>';
  }
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  if (c == 'v' || c == 's' || c == 'S')
    return cur_row + 1;
  if (c == '^' || c == 'w' || c == 'W')
    return cur_row - 1;
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  if (c == '>' || c == 'd' || c == 'D')
    return cur_col + 1;
  if (c == '<' || c == 'a' || c == 'A')
    return cur_col - 1;
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t *state, unsigned int snum) {
  if (snum >= state->num_snakes) return '?';

  snake_t* snake = &state->snakes[snum];
  char head = get_board_at(state, snake->head_row, snake->head_col);
  unsigned int next_row = get_next_row(snake->head_row, head);
  unsigned int next_col = get_next_col(snake->head_col, head);

  if (next_row >= state->num_rows) return '?';
  if (next_col >= strlen(state->board[next_row]) - 1) return '?';
  return get_board_at(state, next_row, next_col);
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t *state, unsigned int snum) {
  if (snum >= state->num_snakes) return;

  snake_t* snake = &state->snakes[snum];
  char head = get_board_at(state, snake->head_row, snake->head_col);
  unsigned int next_row = get_next_row(snake->head_row, head);
  unsigned int next_col = get_next_col(snake->head_col, head);

  if (next_row >= state->num_rows) return;
  if (next_col >= strlen(state->board[next_row]) - 1) return;

  set_board_at(state, snake->head_row, snake->head_col, head_to_body(head));
  set_board_at(state, next_row, next_col, head);
  snake->head_row = next_row;
  snake->head_col = next_col;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t *state, unsigned int snum) {
  if (snum >= state->num_snakes) return;

  snake_t* snake = &state->snakes[snum];
  char tail = get_board_at(state, snake->tail_row, snake->tail_col);
  unsigned int next_row = get_next_row(snake->tail_row, tail);
  unsigned int next_col = get_next_col(snake->tail_col, tail);

  if (next_row >= state->num_rows) return;
  if (next_col >= strlen(state->board[next_row]) - 1) return;

  set_board_at(state, snake->tail_row, snake->tail_col, ' ');
  set_board_at(state, next_row, next_col, body_to_tail(get_board_at(state, next_row, next_col)));
  snake->tail_row = next_row;
  snake->tail_col = next_col;
}

/* Task 4.5 */
void update_state(game_state_t *state, int (*add_food)(game_state_t *state)) {
  for (unsigned int i = 0; i < state->num_snakes; ++i) {
    snake_t* snake = &state->snakes[i];
    if (!snake->live) continue;  // Dead snake can not move.
    char next = next_square(state, i);
    if (next == '#' || is_snake(next)) {
      // alive -> dead
      set_board_at(state, snake->head_row, snake->head_col, 'x');
      snake->live = false;
    }
    else if (next == '*') {
      // eat fruit and generate a new fruit
      update_head(state, i);
      // Should this line be placed at the last of this function?
      if (add_food) add_food(state);
    }
    else if (next == ' ') {
      // just move
      update_head(state, i);
      update_tail(state, i);
    }
    else {
      // should never happen
      fprintf(stderr, "wrong board");
      exit(1);
    }
  }
}

/* Task 5.1 */
char *read_line(FILE *fp) {
#define BUFSIZE 256

  char buff[BUFSIZ] = {0};
  char* line = NULL;
  size_t len = 0;
  while (fgets(buff, BUFSIZ, fp)) {
    size_t buff_len = strlen(buff);
    line = realloc(line, len + buff_len + 1);
    memcpy(&line[len], buff, buff_len + 1);
    len += buff_len;
    if (buff[buff_len - 1] == '\n') {
      return line;
    }
  }
  return NULL;

#undef BUFSIZE
}

/* Task 5.2 */
game_state_t *load_board(FILE *fp) {
  game_state_t* state = (game_state_t*)malloc(sizeof(game_state_t));
  state->num_snakes = 0;
  state->snakes = NULL;
  state->num_rows = 0;
  state->board = NULL;

  char* line = NULL;
  size_t size_board = 8;  // initial size to reduce malloc number
  state->board = malloc(size_board * sizeof(char*));
  while ((line = read_line(fp))) {
    state->num_rows += 1;
    if (state->num_rows > size_board) {
      size_board *= 2;
      state->board = realloc(state->board, size_board * sizeof(char*));
    }
    state->board[state->num_rows - 1] = line;
  }
  // shrink to fit
  if (state->num_rows == 0) {
    free(state->board);
    state->board = NULL;
  }
  else if (size_board > state->num_rows) {
    state->board = realloc(state->board, state->num_rows * sizeof(char*));
  }
  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t *state, unsigned int snum) {
  if (snum >= state->num_snakes) return;

  snake_t* snake = &state->snakes[snum];
  unsigned int cur_row = snake->tail_row;
  unsigned int cur_col = snake->tail_col;
  char cur_chr = get_board_at(state, cur_row, cur_col);

  if (!is_tail(cur_chr)) return;

  while (!is_head(cur_chr)) {
    cur_row = get_next_row(cur_row, cur_chr);
    cur_col = get_next_col(cur_col, cur_chr);
    cur_chr = get_board_at(state, cur_row, cur_col);
    if (!is_snake(cur_chr)) return;
  }

  // cur_chr is head
  snake->head_row = cur_row;
  snake->head_col = cur_col;
}

/* Task 6.2 */
game_state_t *initialize_snakes(game_state_t *state) {
  state->num_snakes = 0;
  state->snakes = NULL;

  size_t size_snakes = 8;  // initial size to reduce malloc number
  state->snakes = malloc(size_snakes * sizeof(snake_t));

  // scan the board to find all snakes
  for (unsigned int i = 0; i < state->num_rows; ++i) {
    size_t num_col = strlen(state->board[i]) - 1;
    for (unsigned int j = 0; j < num_col; ++j) {
      char ch = get_board_at(state, i, j);
      if (is_tail(ch)) {
        state->num_snakes += 1;
        if (state->num_snakes > size_snakes) {
          size_snakes *= 2;
          state->snakes = realloc(state->snakes, size_snakes * sizeof(snake_t));
        }
        unsigned int snum = state->num_snakes - 1;
        state->snakes[snum].live = true;
        state->snakes[snum].tail_row = i;
        state->snakes[snum].tail_col = j;
        find_head(state, snum);
      }
    }
  }

  // shrink to fit
  if (state->num_snakes == 0) {
    free(state->snakes);
    state->snakes = NULL;
  }
  else if (size_snakes > state->num_snakes) {
    state->snakes = realloc(state->snakes,
      state->num_snakes * sizeof(snake_t));
  }

  return state;
}
