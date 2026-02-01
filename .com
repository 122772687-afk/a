<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>Sky后台管理系统</title>
<!-- 核心CDN依赖 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/element-plus/dist/index.css">
<script src="https://unpkg.com/vue@3/dist/vue.global.prod.js"></script>
<script src="https://cdn.jsdelivr.net/npm/element-plus/dist/index.full.js"></script>
<script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/blueimp-md5@2.19.0/js/md5.min.js"></script>
<!-- 字体图标 -->
<link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<style>
  /* 全局基础配置 - 高级感核心 */
  * { 
    margin: 0; 
    padding: 0; 
    box-sizing: border-box; 
    transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
    font-family: "Inter", "Microsoft YaHei", "PingFang SC", sans-serif;
  }
  html, body {
    width: 100%;
    height: 100%;
    overflow: hidden;
    color: #2D3748;
    /* 高级背景：渐变+噪点纹理 */
    background: linear-gradient(135deg, #6366F1, #8B5CF6, #EC4899);
    background-size: 400% 400%;
    animation: bgGradient 15s ease infinite;
    background-attachment: fixed;
  }
  /* 背景渐变动效 */
  @keyframes bgGradient {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
  }
  /* 玻璃拟态通用类 - 高级版 */
  .glass {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.1);
    border-radius: 16px;
  }
  /* 渐变文字通用类 */
  .text-grad {
    background-clip: text;
    -webkit-background-clip: text;
    color: transparent;
    background: linear-gradient(90deg, #6366F1, #EC4899);
  }
  /* 呼吸动效 - 聚焦/悬浮 */
  @keyframes breathe {
    0% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0.4); }
    50% { box-shadow: 0 0 20px 0 rgba(255, 255, 255, 0.6); }
    100% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0.4); }
  }
  /* 淡入淡出通用动效 */
  .fade-enter-active, .fade-leave-active {
    transition: opacity 0.3s ease;
  }
  .fade-enter-from, .fade-leave-to {
    opacity: 0;
  }

  /* 登录页 - 高级感核心设计 */
  .login-box {
    width: 100vw;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
    position: relative;
    z-index: 1;
  }
  /* 登录页装饰点 */
  .login-box::before, .login-box::after {
    content: '';
    position: absolute;
    width: 200px;
    height: 200px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.08);
    z-index: -1;
  }
  .login-box::before {
    top: 10%;
    left: 20%;
  }
  .login-box::after {
    bottom: 10%;
    right: 20%;
  }
  .login-card {
    width: 100%;
    max-width: 420px;
    padding: 60px 40px;
    position: relative;
    z-index: 2;
  }
  .login-card:hover {
    box-shadow: 0 12px 40px 0 rgba(31, 38, 135, 0.15);
    transform: translateY(-5px);
  }
  .login-card h1 {
    text-align: center;
    font-size: 36px;
    font-weight: 700;
    margin-bottom: 40px;
    letter-spacing: 3px;
  }
  /* 登录输入框 - 高级感优化 */
  .login-input {
    --el-input-border-color: transparent;
    --el-input-hover-border-color: transparent;
    --el-input-focus-border-color: transparent;
    --el-input-text-color: #fff;
    --el-input-placeholder-text-color: rgba(255, 255, 255, 0.7);
    background: rgba(255, 255, 255, 0.08) !important;
    border-radius: 12px !important;
    height: 56px !important;
    font-size: 16px !important;
    padding: 0 20px !important;
    margin-bottom: 20px !important;
  }
  .login-input:focus-within {
    animation: breathe 2s ease infinite;
  }
  .login-input .el-input__prefix {
    color: rgba(255, 255, 255, 0.9) !important;
    font-size: 20px !important;
    margin-right: 12px !important;
  }
  /* 记住密码 */
  .remember-pwd { 
    margin: 10px 0 30px; 
    font-size: 14px; 
    color: rgba(255, 255, 255, 0.8);
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .el-checkbox__inner {
    background: rgba(255, 255, 255, 0.08) !important;
    border: 1px solid rgba(255, 255, 255, 0.2) !important;
    border-radius: 4px !important;
  }
  /* 登录按钮 - 渐变+动效 */
  .login-btn {
    width: 100%;
    height: 56px !important;
    font-size: 18px !important;
    font-weight: 600 !important;
    border-radius: 12px !important;
    background: linear-gradient(90deg, #6366F1, #EC4899) !important;
    border: none !important;
  }
  .login-btn:hover {
    background: linear-gradient(90deg, #4F46E5, #DB2777) !important;
    transform: scale(1.02);
  }
  .login-btn:active {
    transform: scale(0.98);
  }

  /* 后台主容器 - 高级感布局 */
  .admin-box {
    width: 100vw;
    height: 100vh;
    display: none;
    flex-direction: column;
    padding: 24px;
    gap: 24px;
  }
  /* 头部导航 - 高级玻璃拟态 */
  .admin-header {
    height: 72px;
    padding: 0 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .header-left { 
    display: flex; 
    align-items: center; 
    gap: 16px; 
    cursor: pointer; 
  }
  .header-left i { 
    font-size: 24px; 
    color: #fff;
  }
  .header-left span {
    font-size: 20px;
    font-weight: 600;
  }
  .header-right { 
    display: flex; 
    align-items: center; 
    gap: 30px; 
  }
  .user-info { 
    display: flex; 
    align-items: center; 
    gap: 12px; 
    font-size: 14px; 
    color: rgba(255, 255, 255, 0.9);
  }
  .role-tag, .level-tag {
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    background: rgba(255, 255, 255, 0.08);
    color: rgba(255, 255, 255, 0.9);
  }
  .header-btn {
    cursor: pointer;
    padding: 8px 16px;
    border-radius: 12px;
    font-size: 14px;
    color: rgba(255, 255, 255, 0.8);
    border: 1px solid transparent;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .header-btn:hover { 
    background: rgba(255, 255, 255, 0.08);
    color: #fff;
    transform: translateY(-2px);
  }
  .logout-btn {
    color: rgba(255, 107, 107, 0.9);
  }
  .logout-btn:hover {
    background: rgba(255, 107, 107, 0.1);
  }

  /* 核心内容区 - 分层布局 */
  .admin-content {
    flex: 1;
    display: flex;
    gap: 24px;
    height: calc(100% - 72px);
  }
  /* 侧边栏 - 高级感+平滑动画 */
  .sidebar {
    width: 240px;
    padding: 24px 0;
    flex-shrink: 0;
  }
  .sidebar-collapse {
    width: 80px;
  }
  .menu-item {
    padding: 16px 30px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 16px;
    color: rgba(255, 255, 255, 0.8);
    font-size: 15px;
    font-weight: 500;
    white-space: nowrap;
  }
  .menu-item i { 
    font-size: 20px; 
    width: 24px;
    text-align: center;
    color: rgba(255, 255, 255, 0.9);
  }
  .menu-item.active {
    background: linear-gradient(90deg, rgba(99, 102, 241, 0.2), transparent);
    color: #fff;
    border-left: 4px solid #6366F1;
  }
  .menu-item:hover:not(.active) {
    background: rgba(255, 255, 255, 0.05);
    color: #fff;
    transform: translateX(5px);
  }
  .sidebar-collapse .menu-item {
    justify-content: center;
    padding: 16px 0;
  }

  /* 主内容区 - 高级玻璃拟态 */
  .main-content {
    flex: 1;
    padding: 30px;
    overflow-y: auto;
  }
  .main-content::-webkit-scrollbar {
    width: 6px;
  }
  .main-content::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.2);
    border-radius: 3px;
  }
  .content-title {
    font-size: 24px;
    font-weight: 600;
    color: #fff;
    margin-bottom: 24px;
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }
  .content-card {
    padding: 30px;
    margin-bottom: 24px;
  }
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    padding-bottom: 16px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }
  .card-title {
    font-size: 18px;
    font-weight: 600;
    color: #fff;
  }
  /* 搜索框 - 后台高级版 */
  .search-box {
    display: flex;
    gap: 12px;
    align-items: center;
  }
  .search-input {
    width: 280px;
    background: rgba(255, 255, 255, 0.08) !important;
    border: none !important;
    border-radius: 12px !important;
    color: #fff !important;
  }
  .search-input ::placeholder {
    color: rgba(255, 255, 255, 0.7) !important;
  }
  /* 通用按钮 - 高级渐变 */
  .btn {
    padding: 8px 20px;
    border-radius: 12px;
    border: none;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    color: #fff;
    background: linear-gradient(90deg, #6366F1, #8B5CF6);
  }
  .btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
  }
  .btn-success { background: linear-gradient(90deg, #10B981, #059669); }
  .btn-danger { background: linear-gradient(90deg, #EF4444, #DC2626); }
  .btn-warning { background: linear-gradient(90deg, #F59E0B, #D97706); }
  .btn-sm { padding: 4px 12px; font-size: 12px; border-radius: 8px; }

  /* 表格 - 高级玻璃拟态 */
  .el-table {
    --el-table-bg-color: transparent;
    --el-table-header-text-color: rgba(255, 255, 255, 0.9);
    --el-table-row-text-color: rgba(255, 255, 255, 0.8);
    --el-table-border-color: rgba(255, 255, 255, 0.1);
    --el-table-row-hover-bg-color: rgba(255, 255, 255, 0.08);
  }
  .el-table th {
    font-weight: 600;
    background: rgba(255, 255, 255, 0.05) !important;
  }
  .el-table tr {
    background: transparent !important;
  }
  .el-table td, .el-table th {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
  }

  /* 弹窗 - 高级玻璃拟态 */
  .el-dialog {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 16px;
    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.1);
  }
  .el-dialog__header {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    padding: 20px 24px 16px;
  }
  .el-dialog__title {
    font-weight: 600;
    color: #fff;
    font-size: 18px;
  }
  .el-dialog__body {
    padding: 24px;
    color: rgba(255, 255, 255, 0.9);
  }
  .el-dialog__footer {
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    padding: 16px 24px 20px;
  }
  .el-form-item__label {
    color: rgba(255, 255, 255, 0.9) !important;
  }
  .el-input, .el-select, .el-input-number {
    --el-input-border-color: rgba(255, 255, 255, 0.2);
    --el-input-hover-border-color: rgba(255, 255, 255, 0.3);
    --el-input-focus-border-color: #6366F1;
    --el-input-text-color: #fff;
    --el-input-placeholder-text-color: rgba(255, 255, 255, 0.7);
    background: rgba(255, 255, 255, 0.08) !important;
    border-radius: 12px !important;
  }
  .el-select-dropdown {
    background: rgba(45, 55, 72, 0.9) !important;
    border: 1px solid rgba(255, 255, 255, 0.2) !important;
    border-radius: 12px !important;
  }
  .el-select-dropdown__item {
    color: rgba(255, 255, 255, 0.9) !important;
  }
  .el-select-dropdown__item:hover {
    background: rgba(99, 102, 241, 0.2) !important;
  }

  /* 个人信息页 - 高级感 */
  .user-info-card {
    text-align: center;
    padding: 40px 30px;
  }
  .user-avatar {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    background: linear-gradient(90deg, #6366F1, #EC4899);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 48px;
    margin: 0 auto 24px;
    box-shadow: 0 0 30px rgba(99, 102, 241, 0.3);
  }
  .user-name {
    font-size: 24px;
    font-weight: 600;
    color: #fff;
    margin-bottom: 12px;
  }
  .user-role {
    display: inline-block;
    padding: 8px 20px;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.08);
    color: rgba(255, 255, 255, 0.9);
    font-size: 14px;
    margin-bottom: 30px;
  }
  .info-item {
    display: flex;
    justify-content: space-between;
    padding: 16px 0;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    font-size: 15px;
    color: rgba(255, 255, 255, 0.8);
  }
  .info-item label {
    font-weight: 500;
    color: rgba(255, 255, 255, 0.9);
  }

  /* 日志空状态 - 高级感 */
  .log-empty {
    text-align: center;
    padding: 60px 0;
    color: rgba(255, 255, 255, 0.7);
  }
  .log-empty i {
    font-size: 60px;
    margin-bottom: 20px;
    color: rgba(255, 255, 255, 0.3);
  }
</style>
</head>
<body>
  <div id="app">
    <!-- 登录页 - 核心登录功能+高级视觉 -->
    <div class="login-box" v-show="!isLogin">
      <div class="login-card glass">
        <h1 class="text-grad">Sky管理系统</h1>
        <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" label-width="0px" size="large">
          <el-form-item prop="username">
            <el-input 
              v-model="loginForm.username" 
              placeholder="请输入登录账号" 
              prefix-icon="el-icon-user"
              class="login-input glass"
              @keyup.enter="handleLogin"
            ></el-input>
          </el-form-item>
          <el-form-item prop="password">
            <el-input 
              v-model="loginForm.password" 
              type="password" 
              placeholder="请输入登录密码" 
              prefix-icon="el-icon-lock"
              class="login-input glass"
              @keyup.enter="handleLogin"
            ></el-input>
          </el-form-item>
          <el-form-item class="remember-pwd">
            <el-checkbox v-model="loginForm.remember" />
            <span>记住密码</span>
          </el-form-item>
          <el-form-item>
            <el-button 
              type="primary" 
              class="login-btn"
              @click="handleLogin" 
              :loading="loginLoading"
            >
              登 录 系 统
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>

    <!-- 后台主容器 - 登录后展示 -->
    <div class="admin-box" id="adminBox">
      <!-- 头部导航 - 含退出登录 -->
      <header class="admin-header glass">
        <div class="header-left" @click="toggleSidebar">
          <i class="fa-solid fa-bars"></i>
          <span class="text-grad" v-show="!sidebarCollapse">Sky后台管理系统</span>
        </div>
        <div class="header-right">
          <div class="user-info">
            <span>欢迎回来，{{ currentUser.username }}</span>
            <span class="role-tag">{{ roleMap[currentUser.role] }}</span>
          </div>
          <div class="header-btn" @click="goPage('userInfo')">
            <i class="fa-solid fa-user"></i>
            <span v-show="!sidebarCollapse">个人信息</span>
          </div>
          <div class="header-btn logout-btn" @click="handleLogout">
            <i class="fa-solid fa-right-from-bracket"></i>
            <span v-show="!sidebarCollapse">退出登录</span>
          </div>
        </div>
      </header>

      <!-- 核心内容区 -->
      <div class="admin-content">
        <!-- 侧边栏 -->
        <aside class="sidebar glass" :class="{ 'sidebar-collapse': sidebarCollapse }">
          <div 
            class="menu-item" 
            :class="{ active: currentPage === 'userList' }" 
            @click="goPage('userList')" 
            v-show="currentUser.role !== 'user'"
          >
            <i class="fa-solid fa-users"></i>
            <span v-show="!sidebarCollapse">账号管理</span>
          </div>
          <div 
            class="menu-item" 
            :class="{ active: currentPage === 'logList' }" 
            @click="goPage('logList')" 
            v-show="currentUser.role !== 'user'"
          >
            <i class="fa-solid fa-file-lines"></i>
            <span v-show="!sidebarCollapse">使用日志</span>
          </div>
          <div 
            class="menu-item" 
            :class="{ active: currentPage === 'userInfo' }" 
            @click="goPage('userInfo')"
          >
            <i class="fa-solid fa-id-card"></i>
            <span v-show="!sidebarCollapse">个人信息</span>
          </div>
        </aside>

        <!-- 主内容区 -->
        <main class="main-content glass">
          <!-- 账号管理页面 -->
          <div v-show="currentPage === 'userList'">
            <h2 class="content-title">账号管理</h2>
            <div class="content-card glass">
              <div class="card-header">
                <h3 class="card-title">账号列表</h3>
                <div class="search-box">
                  <el-input 
                    v-model="userSearchKey" 
                    placeholder="请输入账号名搜索" 
                    prefix-icon="el-icon-search" 
                    class="search-input glass"
                    @keyup.enter="filterUserList"
                  ></el-input>
                  <el-button type="primary" icon="el-icon-plus" class="btn" @click="openAddUserDialog">添加账号</el-button>
                </div>
              </div>
              <el-table :data="filteredUserList" border stripe size="medium" style="width:100%;">
                <el-table-column prop="username" label="账号" align="center" width="120"></el-table-column>
                <el-table-column prop="role" label="角色" align="center" width="120">
                  <template #default="scope">
                    <span class="role-tag">{{ roleMap[scope.row.role] }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="level" label="等级" align="center" width="100"></el-table-column>
                <el-table-column prop="createTime" label="创建时间" align="center" width="200"></el-table-column>
                <el-table-column prop="lastLoginTime" label="最后登录" align="center" width="200"></el-table-column>
                <el-table-column label="操作" align="center" width="200">
                  <template #default="scope">
                    <el-button type="primary" size="small" icon="el-icon-edit" class="btn btn-sm" @click="openEditUserDialog(scope.row)" v-if="scope.row.role !== 'author' || currentUser.role === 'author'">编辑</el-button>
                    <el-button type="warning" size="small" icon="el-icon-key" class="btn btn-sm btn-warning" @click="openResetPwdDialog(scope.row)" style="margin:0 5px;">重置密码</el-button>
                    <el-button type="danger" size="small" icon="el-icon-delete" class="btn btn-sm btn-danger" @click="handleDeleteUser(scope.row)" v-if="scope.row.username !== 'author' && (currentUser.role === 'author' || (currentUser.role === 'admin' && scope.row.role === 'user'))"></el-button>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </div>

          <!-- 使用日志页面 -->
          <div v-show="currentPage === 'logList'">
            <h2 class="content-title">使用日志</h2>
            <div class="content-card glass">
              <div class="card-header">
                <h3 class="card-title">操作日志列表</h3>
                <div class="search-box">
                  <el-input 
                    v-model="logFilter" 
                    placeholder="请输入关键词筛选" 
                    prefix-icon="el-icon-search" 
                    class="search-input glass"
                    @keyup.enter="filterLogList"
                  ></el-input>
                  <el-button type="danger" icon="el-icon-delete" class="btn btn-danger" @click="handleClearLog">清空日志</el-button>
                  <el-button type="primary" icon="el-icon-export" class="btn" @click="exportLog">导出日志</el-button>
                </div>
              </div>
              <el-table :data="filterLogList" border stripe size="medium" style="width:100%;" v-if="filterLogList.length > 0">
                <el-table-column prop="operator" label="操作人" align="center" width="120"></el-table-column>
                <el-table-column prop="type" label="操作类型" align="center" width="120">
                  <template #default="scope">
                    <span class="role-tag">{{ logTypeMap[scope.row.type] }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="target" label="操作对象" align="center" width="150"></el-table-column>
                <el-table-column prop="time" label="操作时间" align="center" width="200"></el-table-column>
                <el-table-column prop="ip" label="操作IP" align="center" width="150"></el-table-column>
              </el-table>
              <div class="log-empty" v-else>
                <i class="fa-solid fa-file-circle-question"></i>
                <p>暂无操作日志记录</p>
              </div>
            </div>
          </div>

          <!-- 个人信息页面 -->
          <div v-show="currentPage === 'userInfo'">
            <h2 class="content-title">个人信息</h2>
            <div class="content-card glass user-info-card">
              <div class="user-avatar">
                <i class="fa-solid fa-user"></i>
              </div>
              <h3 class="user-name">{{ currentUser.username }}</h3>
              <div class="user-role">{{ roleMap[currentUser.role] }} · 等级{{ currentUser.level }}</div>
              <div class="info-item">
                <label>登录账号</label>
                <span>{{ currentUser.username }}</span>
              </div>
              <div class="info-item">
                <label>用户角色</label>
                <span>{{ roleMap[currentUser.role] }}</span>
              </div>
              <div class="info-item">
                <label>账号等级</label>
                <span>{{ currentUser.level }}</span>
              </div>
              <div class="info-item">
                <label>创建时间</label>
                <span>{{ currentUser.createTime }}</span>
              </div>
              <div class="info-item" v-if="currentUser.lastLoginTime">
                <label>最后登录</label>
                <span>{{ currentUser.lastLoginTime }}</span>
              </div>
              <el-button type="primary" icon="el-icon-key" class="btn" style="margin-top:30px;" @click="openEditPwdDialog">修改密码</el-button>
            </div>
          </div>
        </main>
      </div>
    </div>

    <!-- 新增/编辑账号弹窗 -->
    <el-dialog title="添加账号" :visible.sync="addUserDialogVisible" width="400px" center>
      <el-form ref="userFormRef" :model="userForm" :rules="userRules" label-width="80px" size="medium">
        <el-form-item prop="username">
          <el-label>账号</el-label>
          <el-input v-model="userForm.username" placeholder="请输入账号"></el-input>
        </el-form-item>
        <el-form-item prop="password" v-if="!isEditUser">
          <el-label>密码</el-label>
          <el-input v-model="userForm.password" type="password" placeholder="请输入密码（至少6位）"></el-input>
        </el-form-item>
        <el-form-item prop="role">
          <el-label>角色</el-label>
          <el-select v-model="userForm.role" placeholder="请选择角色">
            <el-option label="管理员" value="admin" v-if="currentUser.role === 'author'"></el-option>
            <el-option label="普通用户" value="user"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item prop="level">
          <el-label>等级</el-label>
          <el-input-number v-model="userForm.level" :min="1" style="width:100%;"></el-input-number>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addUserDialogVisible = false" class="btn" style="background: rgba(255,255,255,0.1);">取消</el-button>
        <el-button type="primary" @click="handleSaveUser" class="btn">确定</el-button>
      </template>
    </el-dialog>

    <!-- 重置密码弹窗 -->
    <el-dialog title="重置密码" :visible.sync="resetPwdDialogVisible" width="400px" center>
      <el-form ref="resetPwdFormRef" :model="resetPwdForm" :rules="resetPwdRules" label-width="80px" size="medium">
        <el-form-item prop="password">
          <el-label>新密码</el-label>
          <el-input v-model="resetPwdForm.password" type="password" placeholder="请输入新密码（至少6位）"></el-input>
        </el-form-item>
        <el-form-item prop="confirmPwd">
          <el-label>确认密码</el-label>
          <el-input v-model="resetPwdForm.confirmPwd" type="password" placeholder="请再次输入新密码"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resetPwdDialogVisible = false" class="btn" style="background: rgba(255,255,255,0.1);">取消</el-button>
        <el-button type="primary" @click="handleResetPwd" class="btn">确定</el-button>
      </template>
    </el-dialog>

    <!-- 修改个人密码弹窗 -->
    <el-dialog title="修改密码" :visible.sync="editPwdDialogVisible" width="400px" center>
      <el-form ref="editPwdFormRef" :model="editPwdForm" :rules="editPwdRules" label-width="80px" size="medium">
        <el-form-item prop="oldPwd">
          <el-label>原密码</el-label>
          <el-input v-model="editPwdForm.oldPwd" type="password" placeholder="请输入原密码"></el-input>
        </el-form-item>
        <el-form-item prop="newPwd">
          <el-label>新密码</el-label>
          <el-input v-model="editPwdForm.newPwd" type="password" placeholder="请输入新密码（至少6位）"></el-input>
        </el-form-item>
        <el-form-item prop="confirmNewPwd">
          <el-label>确认新密码</el-label>
          <el-input v-model="editPwdForm.confirmNewPwd" type="password" placeholder="请再次输入新密码"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editPwdDialogVisible = false" class="btn" style="background: rgba(255,255,255,0.1);">取消</el-button>
        <el-button type="primary" @click="handleEditPwd" class="btn">确定</el-button>
      </template>
    </el-dialog>
  </div>

  <script>
    const { createApp } = Vue
    const { ElMessage, ElMessageBox, ElForm, ElFormItem, ElInput, ElButton, ElCheckbox, ElTable, ElTableColumn, ElDialog, ElSelect, ElOption, ElInputNumber } = ElementPlus

    createApp({
      data() {
        return {
          // 核心登录状态
          isLogin: false,
          loginLoading: false,
          loginForm: {
            username: '',
            password: '',
            remember: false
          },
          // 登录表单校验规则
          loginRules: {
            username: [{ required: true, message: '请输入登录账号', trigger: 'blur' }],
            password: [{ required: true, message: '请输入登录密码', trigger: 'blur' }]
          },
          // 侧边栏状态
          sidebarCollapse: false,
          // 当前页面
          currentPage: 'userList',
          // 角色/日志映射
          roleMap: {
            author: '超级管理员',
            admin: '普通管理员',
            user: '普通用户'
          },
          logTypeMap: {
            login: '系统登录',
            logout: '系统退出',
            add: '添加账号',
            delete: '删除账号',
            edit: '编辑账号',
            resetPwd: '重置密码',
            editPwd: '修改密码',
            export: '导出日志',
            clear: '清空日志'
          },
          // 当前登录用户
          currentUser: {},
          // 账号/日志列表 & 搜索关键词
          userList: [],
          userSearchKey: '',
          logList: [],
          logFilter: '',
          // 账号操作弹窗相关
          addUserDialogVisible: false,
          isEditUser: false,
          editTarget: {},
          userForm: {
            username: '',
            password: '',
            role: 'user',
            level: 1
          },
          userRules: {
            username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
            password: [{ required: true, message: '请输入密码', trigger: 'blur' }, { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }],
            role: [{ required: true, message: '请选择角色', trigger: 'change' }],
            level: [{ required: true, message: '请选择等级', trigger: 'change' }]
          },
          // 密码操作弹窗相关
          resetPwdDialogVisible: false,
          resetPwdForm: {
            password: '',
            confirmPwd: ''
          },
          resetPwdRules: {
            password: [{ required: true, message: '请输入新密码', trigger: 'blur' }, { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }],
            confirmPwd: [{ required: true, message: '请确认新密码', trigger: 'blur' }, { validator: this.confirmPwdValidator, trigger: 'blur' }]
          },
          editPwdDialogVisible: false,
          editPwdForm: {
            oldPwd: '',
            newPwd: '',
            confirmNewPwd: ''
          },
          editPwdRules: {
            oldPwd: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
            newPwd: [{ required: true, message: '请输入新密码', trigger: 'blur' }, { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }],
            confirmNewPwd: [{ required: true, message: '请确认新密码', trigger: 'blur' }, { validator: this.confirmNewPwdValidator, trigger: 'blur' }]
          }
        }
      },
      computed: {
        // 筛选后的账号列表
        filteredUserList() {
          if (!this.userSearchKey) return this.userList
          return this.userList.filter(user => user.username.includes(this.userSearchKey))
        },
        // 筛选后的日志列表
        filterLogList() {
          if (!this.logFilter) return this.logList
          return this.logList.filter(log => 
            log.operator.includes(this.logFilter) || 
            log.target.includes(this.logFilter) || 
            this.logTypeMap[log.type].includes(this.logFilter) || 
            log.ip.includes(this.logFilter)
          )
        }
      },
      created() {
        // 页面初始化 - 加载缓存数据、检查登录态
        this.initData()
        this.checkRememberPwd()
      },
      methods: {
        // 密码一致性校验
        confirmPwdValidator(rule, value, callback) {
          if (value !== this.resetPwdForm.password) callback(new Error('两次输入的密码不一致'))
          else callback()
        },
        confirmNewPwdValidator(rule, value, callback) {
          if (value !== this.editPwdForm.newPwd) callback(new Error('两次输入的密码不一致'))
          else callback()
        },
        // 初始化数据 - 加载账号、日志、登录态缓存
        initData() {
          // 加载账号列表
          const localUsers = localStorage.getItem('sysUserList')
          if (localUsers) {
            this.userList = JSON.parse(localUsers)
          } else {
            // 初始账号：author/admin/user，密码均为123456(MD5加密：e10adc3949ba59abbe56e057f20f883e)
            this.userList = [
              {
                username: 'author',
                password: 'e10adc3949ba59abbe56e057f20f883e',
                role: 'author',
                level: 1,
                createTime: this.formatTime(new Date()),
                lastLoginTime: ''
              },
              {
                username: 'admin',
                password: 'e10adc3949ba59abbe56e057f20f883e',
                role: 'admin',
                level: 1,
                createTime: this.formatTime(new Date()),
                lastLoginTime: ''
              },
              {
                username: 'user',
                password: 'e10adc3949ba59abbe56e057f20f883e',
                role: 'user',
                level: 1,
                createTime: this.formatTime(new Date()),
                lastLoginTime: ''
              }
            ]
            localStorage.setItem('sysUserList', JSON.stringify(this.userList))
          }

          // 加载日志列表
          const localLogs = localStorage.getItem('sysLogList')
          if (localLogs) {
            this.logList = JSON.parse(localLogs)
          } else {
            this.logList = []
            localStorage.setItem('sysLogList', JSON.stringify(this.logList))
          }

          // 检查持久化登录态
          const localLogin = localStorage.getItem('sysLoginState')
          if (localLogin) {
            const loginState = JSON.parse(localLogin)
            if (loginState.isLogin) {
              this.isLogin = true
              this.currentUser = loginState.user
              document.getElementById('adminBox').style.display = 'flex'
              this.addLog('login', this.currentUser.username)
            }
          }
        },
        // 检查记住密码 - 自动填充账号密码
        checkRememberPwd() {
          const localRemember = localStorage.getItem('sysRememberPwd')
          if (localRemember) {
            const rememberInfo = JSON.parse(localRemember)
            this.loginForm.username = rememberInfo.username
            this.loginForm.password = rememberInfo.password
            this.loginForm.remember = true
          }
        },
        // 时间格式化
        formatTime(time) {
          const date = new Date(time)
          const y = date.getFullYear()
          const m = (date.getMonth() + 1).toString().padStart(2, '0')
          const d = date.getDate().toString().padStart(2, '0')
          const h = date.getHours().toString().padStart(2, '0')
          const mm = date.getMinutes().toString().padStart(2, '0')
          const s = date.getSeconds().toString().padStart(2, '0')
          return `${y}-${m}-${d} ${h}:${mm}:${s}`
        },
        // 获取模拟IP
        getIp() {
          return `${Math.floor(Math.random() * 255)}.${Math.floor(Math.random() * 255)}.${Math.floor(Math.random() * 255)}.${Math.floor(Math.random() * 255)}`
        },
        // 添加操作日志
        addLog(type, target) {
          const log = {
            operator: this.currentUser.username,
            type: type,
            target: target || '-',
            time: this.formatTime(new Date()),
            ip: this.getIp()
          }
          this.logList.unshift(log)
          localStorage.setItem('sysLogList', JSON.stringify(this.logList))
        },
        // 侧边栏收缩/展开
        toggleSidebar() {
          this.sidebarCollapse = !this.sidebarCollapse
        },
        // 页面跳转
        goPage(page) {
          this.currentPage = page
          this.userSearchKey = ''
          this.logFilter = ''
        },
        // 账号搜索提示
        filterUserList() {
          ElMessage.success(`搜索账号：${this.userSearchKey || '全部'}`)
        },
        // 核心登录方法 - 全流程校验+状态持久化
        async handleLogin() {
          try {
            // 第一步：表单校验
            await this.$refs.loginFormRef.validate()
            this.loginLoading = true

            // 第二步：密码MD5加密，匹配账号
            const { username, password } = this.loginForm
            const md5Pwd = md5(password)
            const user = this.userList.find(item => item.username === username && item.password === md5Pwd)

            if (user) {
              // 第三步：登录成功 - 更新用户信息+持久化状态
              user.lastLoginTime = this.formatTime(new Date())
              this.userList = this.userList.map(item => item.username === username ? user : item)
              localStorage.setItem('sysUserList', JSON.stringify(this.userList))

              // 持久化登录态
              this.isLogin = true
              this.currentUser = { ...user }
              localStorage.setItem('sysLoginState', JSON.stringify({ isLogin: true, user: this.currentUser }))

              // 处理记住密码
              if (this.loginForm.remember) {
                localStorage.setItem('sysRememberPwd', JSON.stringify({ username, password }))
              } else {
                localStorage.removeItem('sysRememberPwd')
              }

              // 登录成功提示+显示后台+记录日志
              ElMessage.success({ message: '登录成功，欢迎回来！', duration: 2000 })
              document.getElementById('adminBox').style.display = 'flex'
              this.addLog('login', username)
            } else {
              // 账号/密码错误提示
              ElMessage.error({ message: '账号或密码错误，请重新输入！', duration: 2000 })
            }
          } catch (error) {
            // 表单校验失败提示
            ElMessage.warning({ message: error.message || '请完善登录信息！', duration: 2000 })
          } finally {
            // 重置加载状态
            this.loginLoading = false
          }
        },
        // 退出登录 - 清除状态+记录日志
        handleLogout() {
          ElMessageBox.confirm(
            '确定要退出系统吗？',
            '退出提示',
            {
              confirmButtonText: '确定',
              cancelButtonText: '取消',
              type: 'warning',
              background: 'rgba(45,55,72,0.9)',
              confirmButtonClass: 'btn',
              cancelButtonClass: 'btn'
            }
          ).then(() => {
            // 清除登录态
            this.isLogin = false
            localStorage.removeItem('sysLoginState')
            document.getElementById('adminBox').style.display = 'none'
