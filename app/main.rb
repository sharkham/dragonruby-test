PLAYER_W = 100
PLAYER_H = 80
SPEED = 12
FPS = 60

def spawn_target(args)
  size = 64
  {
    x: rand(args.grid.w * 0.4) + args.grid.w * 0.6,
    y: rand(args.grid.h - size * 2) + size,
    w: size,
    h: size,
    path: 'sprites/misc/target.png',
  }
end

def fire_input?(args)
  args.inputs.keyboard.key_down.z || args.inputs.keyboard.key_down.j || args.inputs.controller_one.key_down.a
end

def tick(args)
  args.state.player ||= {
    x: 120,
    y: 280,
    w: PLAYER_W,
    h: PLAYER_H,
    speed: SPEED,
    path: 'sprites/misc/dragon-0.png',
  }
  args.state.fireballs ||= []
  args.state.targets ||= [
    spawn_target(args),
    spawn_target(args),
    spawn_target(args),
  ]
  args.state.score ||= 0
  args.state.timer ||= 30 * FPS

  args.state.timer -= 1

  if args.state.timer < 0
    game_over_tick(args)
    return
  end

  handle_player_movement(args)
  spit_fire(args)
  remove_hit_objects(args)

  args.outputs.sprites << [
    args.state.player,
    args.state.fireballs,
    args.state.targets,
  ]

  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Score: #{args.state.score}",
    size_enum: 4,
  }
  labels << {
    x: args.grid.w - 40,
    y: args.grid.h - 40,
    text: "Time left: #{(args.state.timer / FPS).round}",
    size_enum: 2,
    alignment_enum: 2,
  }
  args.outputs.labels << labels
end

HIGH_SCORE_FILE = "high-score.txt"
def game_over_tick(args)
  args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

  if !args.state.saved_high_score.to_i && args.state.score > args.state.high_score.to_i
    args.gtk.write_file(HIGH_SCORE_FILE, args.state.score.to_s)
    args.state.saved_high_score = true
  end

  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Game Over!",
    size_enum: 10,
  }
  labels << {
    x: 40,
    y: args.grid.h - 90,
    text: "Score: #{args.state.score}",
    size_enum: 4,
  }
  labels << {
    x: 40,
    y: args.grid.h - 132,
    text: "Fire to restart",
    size_enum: 2,
  }

  if args.state.timer <- 30 && fire_input?(args)
    $gtk.reset
  end

  if args.state.score.to_i > args.state.high_score.to_i
    labels << {
      x: 260,
      y: args.grid.h - 90,
      text: "New high-score!",
      size_enum: 3,
    }
  else
    labels << {
      x: 260,
      y: args.grid.h - 90,
      text: "Score to beat: #{args.state.high_score}",
      size_enum: 3,
    }
  end

  args.outputs.labels << labels
end

def spit_fire(args)
  if fire_input?(args)
    args.state.fireballs << {
      x: args.state.player.x + args.state.player.w,
      y: args.state.player.y + (args.state.player.h/6),
      w: 32,
      h: 32,
      path: 'sprites/misc/fireball.png',
    }
  end

  args.state.fireballs.each do |fireball|
    fireball.x += args.state.player.speed + 2

    if fireball.x > args.grid.w
      fireball.dead = true
      next
    end

    args.state.targets.each do |target|
      if args.geometry.intersect_rect?(target, fireball)
        target.dead = true
        fireball.dead = true
        args.state.score += 1
        args.state.targets << spawn_target(args)
      end
    end
  end
end

def remove_hit_objects(args)
  args.state.targets.reject! { |t| t.dead}
  args.state.fireballs.reject! { |f| f.dead }
end

def handle_player_movement(args)
  if args.inputs.left
    args.state.player.x -= args.state.player.speed
  elsif args.inputs.right
    args.state.player.x += args.state.player.speed
  end

  if args.inputs.up
    args.state.player.y += args.state.player.speed
  elsif args.inputs.down
    args.state.player.y -= args.state.player.speed
  end

  if args.state.player.x +  args.state.player.w > args.grid.w
    args.state.player.x = args.grid.w - args.state.player.w
  end

  if args.state.player.x < 0
    args.state.player.x = 0
  end

  if args.state.player.y + args.state.player.h > args.grid.h
    args.state.player.y = args.grid.h - args.state.player.h
  end

  if args.state.player.y < 0
    args.state.player.y = 0
  end
end

$gtk.reset