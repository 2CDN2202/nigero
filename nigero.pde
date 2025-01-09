int gridSize = 20; // グリッドのサイズ
int cols, rows;    // グリッドの列と行数
int[][] grid;      // 迷路データ
PVector player;    // プレイヤーの位置
PVector playerDir; // プレイヤーの移動方向
ArrayList<PVector> enemies;  // 敵の位置リスト
ArrayList<PVector> enemyDirs; // 敵の移動方向リスト
int score = 0;     // スコア
boolean gameOver = false;
boolean gameClear = false;
int totalCollectibles = 0; // かけらの総数
int collected = 0;         // 取ったかけらの数
int enemySpeed = 10;       // 敵の移動速度（フレームごとのタイマー）
int enemyTimer = 0;        // 敵移動のためのタイマー
int level = 1;             // 現在のレベル

void setup() {
  size(400, 400);
  cols = width / gridSize;
  rows = height / gridSize;
  grid = new int[cols][rows];
  player = new PVector(1, 1);
  playerDir = new PVector(0, 0);
  enemies = new ArrayList<>();
  enemyDirs = new ArrayList<>();
  startLevel();
}

void draw() {
  background(0);
  drawMaze();

  // プレイヤーを描画
  fill(255, 255, 0);
  ellipse(player.x * gridSize + gridSize / 2, player.y * gridSize + gridSize / 2, gridSize * 0.8, gridSize * 0.8);

  // 敵を描画
  fill(255, 0, 0);
  for (PVector enemy : enemies) {
    ellipse(enemy.x * gridSize + gridSize / 2, enemy.y * gridSize + gridSize / 2, gridSize * 0.8, gridSize * 0.8);
  }

  // スコア、レベル、収集状況を表示
  fill(255);
  textSize(16);
  text("Score: " + score, 10, height - 10);
  text("Level: " + level, 10, height - 30);
  text("Collectibles: " + collected + "/" + totalCollectibles, 10, height - 50);

  if (gameOver) {
    displayGameOver();
    return;
  }

  if (gameClear) {
    displayGameClear();
    return;
  }

  movePlayer(); // プレイヤーを動かす
  if (enemyTimer >= enemySpeed) {
    moveEnemies(); // 敵を動かす
    enemyTimer = 0;
  }
  enemyTimer++;

  checkCollisions();
}

void keyPressed() {
  // プレイヤーの移動方向を設定
  if (keyCode == UP) {
    playerDir.set(0, -1);
  } else if (keyCode == DOWN) {
    playerDir.set(0, 1);
  } else if (keyCode == LEFT) {
    playerDir.set(-1, 0);
  } else if (keyCode == RIGHT) {
    playerDir.set(1, 0);
  }
  
  // Rキーでリスタート
  if (key == 'r' || key == 'R') {
    startLevel();
  }

  // Nキーで次のレベルへ進む
  if (key == 'n' || key == 'N') {
    level++;
    startLevel();
  }
}

void movePlayer() {
  // プレイヤーが移動した先の位置
  int nextX = int(player.x + playerDir.x);
  int nextY = int(player.y + playerDir.y);

  // 壁でない場合に移動
  if (grid[nextX][nextY] != 1) {
    player.x = nextX;
    player.y = nextY;

    // かけらを収集
    if (grid[nextX][nextY] == 2) {
      collected++;
      grid[nextX][nextY] = 0; // かけらを消す
      score += 10;

      // すべてのかけらを収集したらクリア
      if (collected == totalCollectibles) {
        gameClear = true;
      }
    }
  }
  playerDir.set(0, 0); // 移動後は停止
}

void moveEnemies() {
  for (int i = 0; i < enemies.size(); i++) {
    PVector enemy = enemies.get(i);
    PVector dir = enemyDirs.get(i);

    // 敵がプレイヤーに近づくための最短方向を選択
    int dx = int(player.x - enemy.x); // 明示的にキャスト
    int dy = int(player.y - enemy.y); // 明示的にキャスト

    // 水平方向または垂直方向に最短経路を選ぶ
    if (abs(dx) > abs(dy)) {
      dir.set(dx > 0 ? 1 : -1, 0); // x方向に移動
    } else {
      dir.set(0, dy > 0 ? 1 : -1); // y方向に移動
    }

    // 移動先が範囲内かつ壁でない場合に移動
    int newX = int(enemy.x + dir.x);
    int newY = int(enemy.y + dir.y);
    if (newX >= 0 && newY >= 0 && newX < cols && newY < rows && grid[newX][newY] != 1) {
      enemy.add(dir);
    }
  }
}

void checkCollisions() {
  for (PVector enemy : enemies) {
    if (player.x == enemy.x && player.y == enemy.y) {
      gameOver = true;
    }
  }
}

void displayGameOver() {
  fill(255, 0, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("GAME OVER!", width / 2, height / 2);
  textSize(16);
  text("Press R to Restart", width / 2, height / 2 + 40);
}

void displayGameClear() {
  fill(0, 255, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("CLEAR!", width / 2, height / 2);
  textSize(16);
  text("Press N for Next Level", width / 2, height / 2 + 40);
}

void drawMaze() {
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (grid[x][y] == 1) {
        fill(50); // 壁の色
        rect(x * gridSize, y * gridSize, gridSize, gridSize);
      } else if (grid[x][y] == 2) {
        fill(0, 255, 0); // かけらの色
        ellipse(x * gridSize + gridSize / 2, y * gridSize + gridSize / 2, gridSize * 0.4, gridSize * 0.4);
      }
    }
  }
}

void startLevel() {
  generateMaze();
  player.set(1, 1);
  playerDir.set(0, 0);
  totalCollectibles = 0;
  collected = 0;

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (grid[x][y] == 2) {
        totalCollectibles++;
      }
    }
  }

  enemies.clear();
  enemyDirs.clear();
  for (int i = 0; i < level; i++) {
    PVector enemyStart = findOpenSpace();
    enemies.add(enemyStart);
    enemyDirs.add(new PVector(0, 0));
  }

  gameOver = false;
  gameClear = false;
}

void generateMaze() {
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (x == 0 || y == 0 || x == cols - 1 || y == rows - 1) {
        grid[x][y] = 1;
      } else {
        grid[x][y] = random(1) < 0.2 ? 1 : 0;
      }
    }
  }

  grid[1][1] = 0;
  grid[1][2] = 0;
  grid[2][1] = 0;

  for (int x = 1; x < cols - 1; x++) {
    for (int y = 1; y < rows - 1; y++) {
      if (grid[x][y] == 0 && random(1) < 0.1) {
        grid[x][y] = 2;
      }
    }
  }
}

PVector findOpenSpace() {
  while (true) {
    int x = int(random(1, cols - 1));
    int y = int(random(1, rows - 1));
    if (grid[x][y] == 0) {
      return new PVector(x, y);
    }
  }
}
