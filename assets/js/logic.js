import $ from 'jquery';
window.jQuery = $;
window.$ = $;
import * as p5 from 'p5';
import socket from './socket';
import JSONFormatter from 'json-formatter-js'

const WIDTH = 500;
const HEIGHT = 500;

// horizontal length
let hl = 5;
// vertical length
let vl = 5;
let board = [];

let colorize, target_colorize;

// init board
let fill_board = () => {
  let col = [];
  for (let i = 0; i < hl; i++) {
    let row = [];
    for (let j = 0; j < vl; j++) {
      row.push({
        color: 0,
        count: 0
      });
    }
    col.push(row);
  }
  return col;
};

function redundancy_clean(color) {
  for (let i = 0; i < hl; i++) {
    for (let j = 0; j < vl; j++) {
      if (board[i][j].color === color) {
        board[i][j].color = 0;
      }
    }
  }
}

// when user change table size
$('#hsize').change(function() {
  hl = $('#hsize').val();
  board = fill_board();
});
$('#vsize').change(function() {
  vl = $('#vsize').val();
  board = fill_board();
});

let s = sk => {
  // make canvas
  sk.setup = () => {
    let canv = sk.createCanvas(WIDTH, HEIGHT);
    canv.parent('canv');

    board = fill_board();
  };

  // draw in table
  sk.draw = () => {
    let w = 1;
    let hd = HEIGHT / hl;
    let vd = WIDTH / vl;
    for (let i = 0; i < hl; i++) {
      for (let j = 0; j < vl; j++) {
        let x = j * vd;
        let y = i * hd;
        if (board[i][j].color === 0) {
          sk.fill('#fff');
        } else if (board[i][j].color === 1) {
          sk.fill('#000');
        } else if (board[i][j].color === 2) {
          sk.fill('#0f0');
        } else if (board[i][j].color === 3) {
          sk.fill('#00f');
        } else if (board[i][j].color === 4) {
          sk.fill('#ff0');
        } else if (board[i][j].color === 5) {
          sk.fill('#f00');
        } else {
          sk.fill('#f0f');
        }
        sk.strokeWeight(w);
        sk.stroke(51);
        sk.rect(x, y, vd, hd);

        sk.textSize(hd / 3);
        if (board[i][j].color === 0) {
          sk.fill('#000');
        } else if (board[i][j].color === 1) {
          sk.fill('#fff');
        } else if (board[i][j].color === 2) {
          sk.fill('#000');
        } else if (board[i][j].color === 3) {
          sk.fill('#fff');
        } else if (board[i][j].color === 4) {
          sk.fill('#000');
        } else if (board[i][j].color === 5) {
          sk.fill('#000');
        } else {
          sk.fill('#fff');
        }
        sk.textAlign(sk.CENTER, sk.CENTER);
        sk.text(Number.parseInt(board[i][j].count), x + vd / 2, y + hd / 2);
      }
    }
  };

  // when mouse is active
  sk.mouseDragged = sk.mouseClicked = sk.mousePressed = () => {
    let mouseX = sk.mouseX;
    let mouseY = sk.mouseY;
    if (!(mouseX >= 0 && mouseX < WIDTH && mouseY >= 0 && mouseY < HEIGHT)) {
      return;
    }
    let value = board_to_string();
    $('#board').val(value[0]);
    $('#point').val(JSON.stringify(value[1]));
    let x = Math.floor(mouseX / (WIDTH / vl));
    let y = Math.floor(mouseY / (HEIGHT / hl));
    switch (sk.mouseButton) {
      case sk.LEFT:
        board[y][x].color = 1;
        break;
      case sk.CENTER:
        redundancy_clean(2);
        board[y][x].color = 2;
        break;
      case sk.RIGHT:
        redundancy_clean(3);
        board[y][x].color = 3;
        break;
      default:
        break;
    }
  };
};
const P5 = new p5(s);

// when point textbox changes
$('#point').change(() => {
  let p = JSON.parse($('#point').val());
  if (p.x >= vl || p.x < 0 || p.y >= hl || p.y < 0) return;
  redundancy_clean(3);
  board[p.y][p.x].color = 3;
  let value = board_to_string();
  $('#board').val(value[0]);
});

$('#board').change(() => {
  board = board_to_list($('#board').val());
});

function board_to_list(str) {
  if (!str) return fill_board();
  let str_list = str.split(',');
  let new_board = [];
  for (let i = 1; i < str_list.length - 1; i++) {
    let s = str_list[i].trim();
    let row = [];
    for (let j = 1; j < str_list[i].length - 1; j++) {
      let num = Number.parseInt(s[j]);
      if (!Number.isNaN(num))
        row.push({
          color: num,
          count: 0
        });
    }
    if (row.length == vl) new_board.push(row);
  }
  if (new_board.length == hl) {
    return new_board;
  } else {
    return fill_board();
  }
}

function board_to_string() {
  let new_board = [];
  let point = { x: 1, y: 1 };
  let wall_row = '';
  for (let i = 0; i < hl + 2; i++) {
    wall_row += '1';
  }
  new_board.push(wall_row);
  for (let i = 0; i < hl; i++) {
    let row = '1';
    for (let j = 0; j < vl; j++) {
      if (board[i][j].color === 3) {
        point = { y: i + 1, x: j + 1 };
        row += '0';
      } else {
        row += board[i][j].color.toString();
      }
    }
    new_board.push(row + '1');
  }
  new_board.push(wall_row);
  return [new_board, point];
}

function child_to_parent(child) {
  while (true) {
    if (!child.parent) return child;
    child.parent.child = child;
    child = child.parent;
  }
}

function clear_all(){
  clearInterval(colorize);
  clearInterval(target_colorize);
  $("#path").text('');
  $("#es").text('');
  $("#button").show();
  $("#error").text("");
}

function set_length(h, v){
  hl = h;
  $("#hsize").val(hl);
  vl = v;
  $("#vsize").val(hl);
}

window.Logic = (function() {
  let start = function() {
    clear_all();
    $("#button").hide();
    let result = board_to_string();
    let channel = socket.channel('maze_socket:lobby');
    channel
      .join()
      .receive('ok', resp => {
        console.log('Joined successfully', resp);
      })
      .receive('error', resp => {
        console.log('Unable to join', resp);
      });
    let algo = $('#algorithm option:selected').val();
    channel
      .push(
        algo,
        {
          board: result[0],
          start_p: result[1]
        },
        20000
      )
      .receive('ok', resp => {
        if (resp.result[0] != 'ok') {
          console.log("fail")
          clear_all();
          $("#error").text("error: check maze board");
          return;
        }
        let config = {
          hoverPreviewEnabled: true,
          animateOpen: true,
          animateClose: true,
          useToJSON: true
        }

        let target = resp.result[1];
        let explored_set = resp.result[2].explored_set;

        let path_json = new JSONFormatter(target, 1, config);
        let path = document.getElementById("path");

        let es_json = new JSONFormatter(explored_set, 1, config);
        let es = document.getElementById("es");

        path.appendChild(path_json.render());
        es.appendChild(es_json.render());

        colorize = setInterval(() => {
          let point = explored_set.pop();
          if (point) {
            let super_point = child_to_parent(point);
            while (true) {
              board[super_point.y - 1][super_point.x - 1].count += 1;
              board[super_point.y - 1][super_point.x - 1].color = 5;
              super_point = super_point.child;
              if (!super_point) {
                break;
              }
            }
          } else {
            target_colorize = setInterval(() => {
              board[target.y - 1][target.x - 1].color = 4;
              target = target.parent;
              if (!target) {
                clearInterval(target_colorize);
              }
            }, 60000 / (vl * hl));
            clearInterval(colorize);
          }
        }, 30000 / (vl * hl));
      })
      .receive('error', reasons => console.log('create failed', reasons))
      .receive('timeout', () => console.log('Networking issue...'));
  };

  let sample1 = () => {
    clear_all();
    set_length(5, 5);
    let s = '1111111,1000001,1011101,1001001,1011101,1001001,1111111';
    board = board_to_list(s);
  };
  let sample2 = () => {
    clear_all();
    set_length(10, 10);
    let s =
      '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,100011110001,110110000001,110100001001,110101101111,110100100111,110000100001,110010111001,100100001101,100110001101,100011100001,111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
    board = board_to_list(s);
  };
  let sample3 = () => {
    clear_all();
    set_length(25, 25);
    let s =
      '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,100000000100010000100000001,100000000110010000100000001,100011100011111111000100001,100000011111000000110100001,100001001100000000001100001,111110001001110001101100001,100000010000000000000100001,100000010000110001100010001,100000110000110001100010001,100010100000110001100010001,101100100000000000000010001,100000100000000010000010001,100001100000000010000010001,100110110000000010000010001,101000010000001110000010001,100000010001000000000010001,100001011001000000000110001,100010001001111100000100001,100110001100110000001100001,100000000111000000011000001,100000000001111111100000001,100000000000010101000000001,100000000000011001000000001,100000000000111111000000001,100000000011100001100000001,111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
    board = board_to_list(s);
  };
  let sample4 = () => {
    clear_all();
    set_length(30, 15);
    let s =
      '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,10001000001000101,10001100001100011,10000000000000101,10100000000000111,10111111111100001,10100000000100001,10000001110100001,10100001111100001,10100111110000001,10100101110000001,10100101111100001,10100111110101001,10100001110101001,10110001110101001,10010000000101001,10010011111101001,10011000000001001,10001111111001001,10001000000001001,10001000000001001,10001111100001001,10001000100001001,10001010111101001,11101010100101001,10101111100001001,10101100000011001,10000111111110001,10000000000000001,10000000000000011,10000000000000101,11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
    board = board_to_list(s);
  };
  let sample5 = () => {
    clear_all();
    set_length(20, 20);
    let s =
      '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,1001100000000000110001,1111111110000000000001,1111000100000111111101,1011100100000111111101,1011100111000111111101,1000000111000000000001,1000000111000111111101,1111110100000000000031,1000000001000000000001,1000000001000000000001,1000000111110011000001,1000000001000011000011,1000000001000011010011,1201000000000011010011,1000000000000011010011,1000000000000000010011,1111000000000000010011,1111011001110000010001,1100011001110000011111,1100011001110000011111,1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
    board = board_to_list(s);
  };
  let sample6 = () => {
    clear_all();
    set_length(30, 30);
    let s = '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,11111111111111110000000010100001,10000000000100010001001010101011,10111111000101110111111010101011,10100011100100000000001010101001,10100010100101111100111010101101,10111010100100000110001110100101,10011010100101110100100000001101,10011010100101010101111111100101,11011010100101010100100010001101,10001010100100010101101011111101,10111010110111110101000010011001,10111010010000000101001110111101,10100010011111111101000000001111,10101011001111111101011111100101,10101001100010000001000000110101,10101010110011111101011110010001,12101000000000000000001110010001,10101111111111111111101110111011,10100000000000000000000100011011,10101111111111111010111101001011,10101000000000001010100001001011,10101011111111101010101001001011,10101000000100101010101001001011,10101001110110101010101101101011,10101011111110101010100100101011,10101000010000101010100100101011,10101001110110101010111100001011,10101001000100101000010000101011,10101001111100111011111111101011,10001000000100000000000000001011,11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
    board = board_to_list(s);
  }
  return {
    start: start,
    sample1: sample1,
    sample2: sample2,
    sample3: sample3,
    sample4: sample4,
    sample5: sample5,
    sample6: sample6
  };
})();
