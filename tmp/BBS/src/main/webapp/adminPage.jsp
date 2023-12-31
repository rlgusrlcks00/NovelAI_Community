<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import="java.io.PrintWriter" %>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/bootstrap.css">
    <link rel="stylesheet" href="./css/3.css">
    <title>관리자 페이지</title>
</head>
<body>
<%
    // 관리자 인증 체크 (예: 세션 또는 로그인 상태 확인)
    boolean isAdmin = false; // 관리자 여부 확인

    // 로그인 세션에서 userID 가져오기
    String userID = (String) session.getAttribute("userID");

    // JDBC 연결 및 SQL 문 실행 준비
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String driverName = "com.mysql.jdbc.Driver";
        String dbURL = "jdbc:mysql://localhost:3306/jsp41";
        String dbUser = "jsp41";
        String dbPassword = "poiu0987";

        Class.forName(driverName);
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // 사용자의 Admin 속성값 조회
        String selectSql = "SELECT Admin FROM User WHERE User_ID = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setString(1, userID);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            int adminValue = rs.getInt("Admin");
            isAdmin = (adminValue == 1); // Admin 속성값이 1이면 isAdmin을 true로 설정
        }

        if (isAdmin) {
            // 게시판 목록 조회
            String selectSqlB = "SELECT * FROM Board";
            pstmt = conn.prepareStatement(selectSqlB);
            rs = pstmt.executeQuery();

%>
            <nav class="navbar navbar-default">
                <div class="container-fluid">
                    <div class="navbar-header">
                        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
                            <span class="sr-only">Toggle navigation</span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                        <a class="navbar-brand" href="#">관리자 페이지</a>
                    </div>

                    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                        <ul class="nav navbar-nav">
                            <li class="active"><a href="adminPage.jsp">게시판 관리</a></li>
                            <li><a href="userManage.jsp">회원 정보 관리</a></li>
                            <li><a href="loginHistory.jsp">로그인 기록</a></li>
                            <li><a href="main.jsp">메인으로 돌아가기</a></li>

                        </ul>

                        <ul class="nav navbar-nav navbar-right">
                            <li><a href="#">관리자</a></li>
                            <li><a href="logoutAction.jsp">로그아웃</a></li>
                        </ul>
                    </div>
                </div>
            </nav>

            <div class="container">
                <h3>게시판 목록</h3>
                <table class="table table-bordered" style="border: 1px solid #000000;">
                    <thead>
                        <tr>
                            <th>게시판 ID</th>
                            <th>게시판 이름</th>
                            <th>작업</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% while (rs.next()) { %>
                            <tr>
                                <td><%= rs.getInt("Board_ID") %></td>
                                <td><%= rs.getString("Board_Name") %></td>
                                <td>
                                    <a href="bbs.jsp?boardID=<%= rs.getInt("Board_ID") %>" class="btn btn-primary btn-sm">게시판 보기</a>
                                    <a href="updateBoard.jsp?boardID=<%= rs.getInt("Board_ID") %>" class="btn btn-primary btn-sm">게시판 수정</a>
                                    <a href="deleteBoardAction.jsp?boardID=<%= rs.getInt("Board_ID") %>" class="btn btn-primary btn-sm" onclick="return confirm('정말로 삭제하시겠습니까?')">게시판 삭제</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>

                <h3>새로운 게시판 생성</h3>
                <form action="addBoardAction.jsp" method="POST">
                    <div class="form-group">
                        <label for="boardName">게시판 이름</label>
                        <input type="text" class="form-control" id="boardName" name="boardName" required>
                    </div>
                    <!-- 필요한 추가 정보 입력 -->

                    <button type="submit" class="btn btn-primary">게시판 생성</button>
                </form>
            </div>

            <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
            <script src="js/bootstrap.js"></script>
<%      
        } else {
            // 관리자 인증 실패 시 처리
            response.sendRedirect("login.jsp"); // 로그인 페이지로 리다이렉트
        }
    } catch (Exception e) {
        out.println("MySQL 데이터베이스 처리에 문제가 발생했습니다.<hr>");
        out.println(e.toString());
        e.printStackTrace();
    } finally {
        if (rs != null) {
            rs.close();
        }
        if (pstmt != null) {
            pstmt.close();
        }
        if (conn != null) {
            conn.close();
        }
    }
%>
</body>
</html>
