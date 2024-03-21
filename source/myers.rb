#!/usr/bin/ruby

class Myers
  attr_accessor :source, :target

  def initialize(source, target)
    self.source = source
    self.target = target
  end

  def myers(stra, strb)
    # 字符串 a 和 b 的长度，分别为 n 和 m
    m = stra.length
    n = strb.length

    # 用于存储每条 K 线上最佳位置的 Map
    v = { 1 => 0 }
    # 用于存储所有深度的所有最佳位置的 Map，用于回溯编辑路径
    vs = { 0 => { 1 => 0 } }

    loop do
      # 外层循环，遍历深度
      (0..m + n).each do |d|
        tmp = {}
        # 内层循环，宽度优先搜索，遍历 K 线
        (-d..d).step(2) do |k|
          down = ((k == -d) || ((k != d) && v[k + 1] > v[k - 1]))
          kPrev = down ? k + 1 : k - 1
          # 获取移动的起点位置
          xStart = v[kPrev]
          yStart = xStart - kPrev
          # 获取移动一步的中间位置，向右或向下
          xMid = down ? xStart : xStart + 1
          yMid = xMid - k
          # 获取移动的终点位置，后续可能会向右下移动。
          xEnd = xMid
          yEnd = yMid

          # 向右下移动，深度始终不变
          while xEnd < m && yEnd < n && stra[xEnd] == strb[yEnd]
            xEnd += 1
            yEnd += 1
          end

          # 记录对应 K 线所能达到的最佳位置
          v[k] = xEnd

          tmp[k] = xEnd

          # 如果两个字符串均到达末端，表示找到了终点，可以结束查找
          if xEnd == m && yEnd == n
            vs[d] = tmp
            # 生成最短编辑路径
            snakes = solution(vs, m, n, d)
            # 打印最短编辑路径
            printDiff(snakes, stra, strb)
            return
          end
        end
        # 记录深度为 D 的所有 K 线的最佳位置
        vs[d] = tmp
      end
    end
  end

  def solution(vs, m, n, d)
    snakes = []
    # 定义位置结构
    pos = { x: m, y: n }

    # 回溯最短编辑路径
    while d > 0
      v = vs[d]
      vPrev = vs[d - 1]

      k = pos[:x] - pos[:y]
      # 判断之前位置到当前位置最开始移动的方式，向下或向右
      down = ((k == -d) || ((k != d) && (vPrev[k + 1] > vPrev[k - 1])))
      kPrev = down ? k + 1 : k - 1

      # 当前位置
      xEnd = v[k]
      yEnd = xEnd - k

      # 之前位置
      xStart = vPrev[kPrev]
      yStart = xStart - kPrev

      # 中间走斜线时的起始位置
      xMid = down ? xStart : xStart + 1
      yMid = xMid - k

      snakes.unshift([xStart, xMid, xEnd])

      pos[:x] = xStart
      pos[:y] = yStart

      d -= 1
    end
    snakes
  end

  def printDiff(snakes, stra, strb)
    diffresult = ''
    yOffset = 0

    snakes.each_with_index do |snake, index|
      s = snake[0]
      m = snake[1]
      e = snake[2]

      # 如果是第一个差异，并且差异的开始点不是字符串头（即两字符串在开始部分有相同子字符串）
      if index === 0 && s != 0
        # 打印所有相同字符，直到s
        (0..s - 1).each do |j|
          diffresult += "  #{stra[j]}\n"
          yOffset += 1
        end
      end
      if m - s == 1
        # 用红色打印删除的字符
        diffresult += "\033[0;31m- #{stra[s]}\033[0m\n"
      else
        # 用绿色打印插入的字符
        diffresult += "\033[0;32m+ #{strb[yOffset]}\033[0m\n"
        yOffset += 1
      end
      # 打印相同的字符
      (0..e - m - 1).each do |i|
        diffresult += "  #{stra[m + i]}\n"
        yOffset += 1
      end
    end
    puts diffresult
  end
end