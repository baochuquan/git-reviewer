require 'gitreviewer/analyze/blame_tree'
require 'gitreviewer/analyze/diff_tree'

module GitReviewer
  class Myers
    # Type: BlameFile
    attr_accessor :source, :target

    def initialize(source, target)
      self.source = source
      self.target = target
    end

    def resolve
      # 字符串 a 和 b 的长度，分别为 n 和 m
      m = source.blame_lines.count
      n = target.blame_lines.count

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
            k_prev = down ? k + 1 : k - 1
            # 获取移动的起点位置
            x_start = v[k_prev]
            y_start = x_start - k_prev
            # 获取移动一步的中间位置，向右或向下
            x_mid = down ? x_start : x_start + 1
            y_mid = x_mid - k
            # 获取移动的终点位置，后续可能会向右下移动。
            x_end = x_mid
            y_end = y_mid

            # 向右下移动，深度始终不变
            while x_end < m && y_end < n && source.blame_lines[x_end] == target.blame_lines[y_end]
              x_end += 1
              y_end += 1
            end

            # 记录对应 K 线所能达到的最佳位置
            v[k] = x_end

            tmp[k] = x_end

            # 如果两个字符串均到达末端，表示找到了终点，可以结束查找
            if x_end == m && y_end == n
              vs[d] = tmp
              # 生成最短编辑路径
              snakes = route(vs, m, n, d)
              # 打印最短编辑路径
              result = build_diff(snakes)
              return result
            end
          end
          # 记录深度为 D 的所有 K 线的最佳位置
          vs[d] = tmp
        end
      end
    end

    def route(vs, m, n, d)
      snakes = []
      # 定义位置结构
      pos = { x: m, y: n }

      # 回溯最短编辑路径
      while d > 0
        v = vs[d]
        v_prev = vs[d - 1]

        k = pos[:x] - pos[:y]
        # 判断之前位置到当前位置最开始移动的方式，向下或向右
        down = ((k == -d) || ((k != d) && (v_prev[k + 1] > v_prev[k - 1])))
        k_prev = down ? k + 1 : k - 1

        # 当前位置
        x_end = v[k]
        y_end = x_end - k

        # 之前位置
        x_start = v_prev[k_prev]
        y_start = x_start - k_prev

        # 中间走斜线时的起始位置
        x_mid = down ? x_start : x_start + 1
        y_mid = x_mid - k

        snakes.unshift([x_start, x_mid, x_end])

        pos[:x] = x_start
        pos[:y] = y_start

        d -= 1
      end
      snakes
    end

    def build_diff(snakes)
      diff_result = []
      y_offset = 0

      snakes.each_with_index do |snake, index|
        s = snake[0]
        m = snake[1]
        e = snake[2]

        # 如果是第一个差异，并且差异的开始点不是字符串头（即两字符串在开始部分有相同子字符串）
        if index === 0 && s != 0
          # 所有相同字符，直到s
          (0..s - 1).each do |j|
            diff_line = DiffLine.new(source.blame_lines[j], target.blame_lines[y_offset], DiffLine::UNCHANGE)
            diff_result.append(diff_line)
            y_offset += 1
          end
        end
        if m - s == 1
          # 用红色打印删除的字符
          diff_line = DiffLine.new(source.blame_lines[s], nil, DiffLine::DELETE)
          diff_result.append(diff_line)
        else
          # 用绿色打印插入的字符
          diff_line = DiffLine.new(nil, target.blame_lines[y_offset], DiffLine::ADD)
          diff_result.append(diff_line)
          y_offset += 1
        end
        # 相同的字符
        (0..e - m - 1).each do |i|
          diff_line = DiffLine.new(source.blame_lines[s], target.blame_lines[y_offset], DiffLine::UNCHANGE)
          diff_result.append(diff_line)
          y_offset += 1
        end
      end

      # 确定属性
      operation = DiffFile::UNKNOWN
      binary = false
      if source.exist? && target.exist?
        operation = DiffFile::MODIFY
        binary = target.binary?
      elsif source.exist? && !target.exist?
        operation = DiffFile::DELETE
        binary = source.binary?
      elsif !source.exist? && target.exist?
        operation = DiffFile::ADD
        binary = target.binary?
      else
        operation = DiffFile::UNKNOWN
        binary = false
      end

      # 确定结果
      result = DiffFile.new(source.file_name, diff_result, operation, binary)

      # # 打印内容
      result.print_meta_info
      Printer.verbose_put "#{result.format_line_diff}"

      return result
    end
  end
end
