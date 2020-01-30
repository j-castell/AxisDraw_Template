PVector[] points;
float pos;

void setup() {
  size(700, 700);
  background(0);
  
  points = new PVector[0];
  
  setupPloter();
  
  generatePoints();
}

void draw() {
  drawPloter(); // Draw on ploter
  doConnection(); // Check connection
}

PVector pointPos(float pos) {
  float x = cos(pos / 8) * 40 * cos(pos / 10) + 350;
  float y = sin(pos / 10) * 50 + 350;
  return new PVector(x, y);
}

void generatePoints() {
  ToDoList = (PVector[]) append(ToDoList, new PVector(-30, 0)); //Command 30 (raise pen)
  PVector point = pointPos(0);
  ToDoList = (PVector[]) append(ToDoList, point);
  ToDoList = (PVector[]) append(ToDoList, new PVector(-31, 0)); //Command 31 (lower pen)
  
  for (int i = 1; i < 400; i++) {
    point = pointPos(i);
    ToDoList = (PVector[]) append(ToDoList, point);
    stroke(255, 0, 0);
    strokeWeight(3);
    point(point.x, point.y);
  }
  
  ToDoList = (PVector[]) append(ToDoList, new PVector(-31, 0)); //Command 31 (lower pen)
  ToDoList = (PVector[]) append(ToDoList, new PVector(-30, 0)); //Command 30 (raise pen)
  ToDoList = (PVector[]) append(ToDoList, new PVector(-35, 0)); //Command 35 (back to 0,0)
}
