-- =============================================================================
-- lazy.nvim のインストール（初回自動）
-- =============================================================================
-- lazy.nvimはNeovimのプラグインマネージャー
-- 初回起動時に自動でGitHubからクローンされる
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
-- runtimepathにlazy.nvimを追加してロード可能にする
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- 基本設定
-- =============================================================================
-- リーダーキーをスペースに設定（<leader>ffなどで使う）
vim.g.mapleader = " "

-- 行番号を表示
vim.opt.number = true

-- タブをスペースに変換
vim.opt.expandtab = true

-- タブ文字の表示幅（2スペース）
vim.opt.tabstop = 2

-- 自動インデント時のスペース数（2スペース）
vim.opt.shiftwidth = 2

-- 検索時に大文字小文字を区別しない
vim.opt.ignorecase = true

-- 検索語に大文字が含まれる場合は区別する（ignorecaseと併用）
vim.opt.smartcase = true

-- =============================================================================
-- キーマップ
-- =============================================================================
-- インサートモードでjjを押すとノーマルモードに戻る（Escの代わり）
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })

-- =============================================================================
-- プラグイン
-- =============================================================================
require("lazy").setup({

  -- ---------------------------------------------------------------------------
  -- tokyonight: カラースキーム
  -- ---------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-treesitter: 高精度なシンタックスハイライト
  -- ---------------------------------------------------------------------------
  -- 言語のパーサーを使って正確な構文解析を行う
  -- 従来の正規表現ベースより賢いハイライトが可能
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- インストール後にパーサーを更新
    config = function()
      -- パーサーのインストール設定
      require("nvim-treesitter").setup({})
      -- 必要なパーサーをインストール
      local languages = { "lua", "javascript", "typescript", "python", "go", "json", "yaml", "markdown" }
      require("nvim-treesitter").install(languages)
    end,
  },

  -- ---------------------------------------------------------------------------
  -- telescope.nvim: ファジーファインダー
  -- ---------------------------------------------------------------------------
  -- ファイル検索、文字列検索、バッファ切り替えなどを高速に行える
  -- <leader>ff でファイル検索、<leader>fg で文字列検索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }, -- 必須の依存ライブラリ
    keys = {
      -- Space + ff: ファイル名で検索
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      -- Space + fg: ファイル内容をgrep検索
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      -- Space + fb: 開いているバッファ一覧
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    },
  },

  -- ---------------------------------------------------------------------------
  -- gitsigns.nvim: Git差分表示
  -- ---------------------------------------------------------------------------
  -- 行番号の横に追加/変更/削除を表示
  -- 変更箇所がひと目でわかる
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Comment.nvim: コメントトグル
  -- ---------------------------------------------------------------------------
  -- gcc: 現在行をコメント/アンコメント
  -- gc + 移動: 範囲をコメント（例: gcip でパラグラフ全体）
  -- ビジュアルモードで選択して gc でも可
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-autopairs: 括弧の自動補完
  -- ---------------------------------------------------------------------------
  -- ( を入力すると自動で ) が追加される
  -- {, [, ", ' なども対応
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- インサートモード時に読み込み（遅延ロード）
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-tree: ファイルツリー
  -- ---------------------------------------------------------------------------
  -- サイドバーにディレクトリ構造を表示
  -- <leader>e でツリーの表示/非表示を切り替え
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- ファイルアイコン表示用
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
      -- netrwを無効化（nvim-treeと競合するため）
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- lualine.nvim: ステータスライン
  -- ---------------------------------------------------------------------------
  -- 画面下部にモード、ブランチ名、ファイル名などを表示
  -- tokyonightテーマに自動で合わせる
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
        },
      })
    end,
  },
})
