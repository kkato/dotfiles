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

-- 24bitカラー（TrueColor）を有効化（モダンなカラースキームに必要）
vim.opt.termguicolors = true

-- 検索時に大文字小文字を区別しない
vim.opt.ignorecase = true

-- 検索語に大文字が含まれる場合は区別する（ignorecaseと併用）
vim.opt.smartcase = true

-- =============================================================================
-- キーマップ
-- =============================================================================
-- インサートモードでjjを押すとノーマルモードに戻る（Escの代わり）
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })

-- hhで行頭の非空白文字に移動（^と同じ）
vim.keymap.set("n", "hh", "^", { noremap = true })

-- llで行末に移動（$と同じ）
vim.keymap.set("n", "ll", "$", { noremap = true })

-- =============================================================================
-- プラグイン
-- =============================================================================
require("lazy").setup({

  -- ---------------------------------------------------------------------------
  -- nvim-treesitter: 高精度なシンタックスハイライト
  -- ---------------------------------------------------------------------------
  -- 言語のパーサーを使って正確な構文解析を行う
  -- 従来の正規表現ベースより賢いハイライトが可能
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- インストール後にパーサーを更新
    config = function()
      require("nvim-treesitter.configs").setup({
        -- 自動インストールする言語のパーサー
        ensure_installed = { "lua", "javascript", "typescript", "python", "go", "json", "yaml", "markdown" },
        -- ハイライト機能を有効化
        highlight = { enable = true },
      })
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
  -- lualine.nvim: ステータスライン
  -- ---------------------------------------------------------------------------
  -- 画面下部にモード、ファイル名、位置などを表示
  -- 見た目がおしゃれになる
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- tokyonight.nvim: カラースキーム
  -- ---------------------------------------------------------------------------
  -- 人気の高いダークテーマ
  -- priority=1000 で他のプラグインより先に読み込む
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-tree.lua: ファイルマネージャー
  -- ---------------------------------------------------------------------------
  -- サイドバー型のファイルツリー
  -- Space + e でツリーを開閉
  -- ファイル操作: a(作成), d(削除), r(名前変更), x(切り取り), c(コピー), p(貼り付け)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- ファイルアイコン表示用
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30, -- サイドバーの幅
        },
        filters = {
          dotfiles = false, -- 隠しファイルを表示（trueで非表示）
        },
      })
      -- Space + e でツリーを開閉
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
      -- Space + o で現在のファイルをツリーで表示
      vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFindFile<cr>", { desc = "Find file in tree" })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- mason.nvim: 言語サーバーのインストーラー
  -- ---------------------------------------------------------------------------
  -- :Mason でUIを開いて言語サーバーを管理できる
  -- mason-lspconfigと連携して自動インストールも可能
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- mason-lspconfig.nvim: masonとlspconfigの連携
  -- ---------------------------------------------------------------------------
  -- ensure_installedで指定した言語サーバーを自動インストール
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- 自動インストールする言語サーバー
        ensure_installed = {
          "gopls",      -- Go
          "pyright",    -- Python
          "ts_ls",      -- TypeScript/JavaScript
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-cmp: 補完エンジン
  -- ---------------------------------------------------------------------------
  -- LSPやスニペットなど様々なソースから補完候補を表示
  -- Tab/Shift+Tabで候補選択、Enterで確定
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP補完ソース
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          -- Ctrl+Space: 補完を手動で開く
          ["<C-Space>"] = cmp.mapping.complete(),
          -- Enter: 選択中の候補を確定
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- Tab: 次の候補へ
          ["<Tab>"] = cmp.mapping.select_next_item(),
          -- Shift+Tab: 前の候補へ
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSPからの補完
        }),
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-lspconfig: LSP設定
  -- ---------------------------------------------------------------------------
  -- 各言語サーバーの設定を行う
  -- キーマップ: gd(定義), K(ホバー), <leader>rn(リネーム), <leader>ca(コードアクション)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      -- nvim-cmpの補完機能をLSPに伝える
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSPがバッファにアタッチされたときのキーマップ設定
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        -- gd: 定義へジャンプ
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        -- gD: 宣言へジャンプ
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        -- gr: 参照一覧を表示
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        -- K: ホバー情報（型情報など）を表示
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        -- Space + rn: シンボルをリネーム
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        -- Space + ca: コードアクション（自動修正など）
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        -- Space + f: フォーマット
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
      end

      -- Go
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Python
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,
  },
})
