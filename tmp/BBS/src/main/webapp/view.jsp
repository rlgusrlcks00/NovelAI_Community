<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import="java.io.PrintWriter" %>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="./css/1.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"></script>
    <title>JSP 게시판 웹 사이트</title>
    <style>

        .container{
            padding-top: 70px;
        }

        body {
            padding-top: 60px;
            background-color: #e2e2e2;
        }
        .panel {
            border-radius: 0px;
            border-color: #ddd;
        }

        .post-font{
            font-size: 24px;
            font-family: 'TheJamsil5Bold';
            font-weight: 100;
        }

        .btn-primary{
            margin:20px 10px 20px 0px ;
        }

        
        .panel-title>h4 {
            color: #333;
            font-weight: 600;
            font-size: 40px;
            font-family: 'TheJamsil5Bold';
            padding-bottom: 20px;
        }
        .panel-body p {
            font-size: 16px;
            color: #555;
        }
        .navbar {
            border-radius: 0px;
            margin-bottom: 2rem;
        }
        .navbar-brand {
            font-size: 20px;
            font-weight: 600;
        }
        .dropdown-menu {
            border-radius: 0px;
            border-color: #ddd;
        }
        .form-control {
            border-radius: 0px;
        }
        .btn {
            border-radius: 0px;
        }
    </style>
</head>
<body>
<%
    String userID = null;
    String userNickName = null;
    String userAdmin = null;

    boolean follow = false;

    if (session.getAttribute("userID") != null) {
        userID = (String) session.getAttribute("userID");
        Connection conn = null;
        PreparedStatement userPstmt = null;
        ResultSet userRs = null;
        try {
            String driverName = "com.mysql.jdbc.Driver";
            String dbURL = "jdbc:mysql://localhost:3306/jsp41";
            String dbUser = "jsp41";
            String dbPassword = "poiu0987";

            Class.forName(driverName);
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            String userSql = "SELECT NickName, Admin FROM User WHERE User_ID = ?";
            userPstmt = conn.prepareStatement(userSql);
            userPstmt.setString(1, userID);
            userRs = userPstmt.executeQuery();
            if (userRs.next()) {
                userNickName = userRs.getString("NickName");
                userAdmin = userRs.getString("Admin");
            }
        } catch (Exception e) {
            out.println("MySQL 데이터베이스 처리에 문제가 발생했습니다.<hr>");
            out.println(e.toString());
            e.printStackTrace();
        } finally {
            if (userPstmt != null) {
                userPstmt.close();
            }
            if (userRs != null) {
                userRs.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }

    int postID = 0;
    if (request.getParameter("postID") != null) {
        postID = Integer.parseInt(request.getParameter("postID"));
    }

    // 게시글 방문 기록 저장 및 조회수 업데이트
    if (userID != null) {
        Connection conn = null;
        PreparedStatement historyPstmt = null;
        try {
            String driverName = "com.mysql.jdbc.Driver";
            String dbURL = "jdbc:mysql://localhost:3306/jsp41";
            String dbUser = "jsp41";
            String dbPassword = "poiu0987";

            Class.forName(driverName);
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            // 이미 방문한 기록이 있는지 확인
            String historyCheckSql = "SELECT * FROM PostHistory WHERE POST_code = ? AND User_ID = ?";
            PreparedStatement historyCheckPstmt = conn.prepareStatement(historyCheckSql);
            historyCheckPstmt.setInt(1, postID);
            historyCheckPstmt.setString(2, userID);
            ResultSet historyCheckRs = historyCheckPstmt.executeQuery();

            if (!historyCheckRs.next()) { // 방문 기록이 없는 경우에만 기록 저장
                String historyInsertSql = "INSERT INTO PostHistory (POST_code, User_ID) VALUES (?, ?)";
                historyPstmt = conn.prepareStatement(historyInsertSql);
                historyPstmt.setInt(1, postID);
                historyPstmt.setString(2, userID);
                historyPstmt.executeUpdate();

                // 조회수 업데이트
                String updateViewCountSql = "UPDATE Post SET ViewCount = (SELECT COUNT(*) FROM PostHistory WHERE POST_code = ?) WHERE POST_code = ?";
                PreparedStatement updateViewCountPstmt = conn.prepareStatement(updateViewCountSql);
                updateViewCountPstmt.setInt(1, postID);
                updateViewCountPstmt.setInt(2, postID);
                updateViewCountPstmt.executeUpdate();
            }
        } catch (Exception e) {
            out.println("MySQL 데이터베이스 처리에 문제가 발생했습니다.<hr>");
            out.println(e.toString());
            e.printStackTrace();
        } finally {
            if (historyPstmt != null) {
                historyPstmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }
    // 게시글 추천 기능을 위한 변수 및 SQL문
    boolean isRecommended = false;
    Connection conn = null; // conn 변수 추가

    int recommendCount = 0;
    String recommendSql = "SELECT * FROM Recommend WHERE POST_code = ? AND User_ID = ?";
    PreparedStatement recommendPstmt = null;
    ResultSet recommendRs = null;
    try {
        String driverName = "com.mysql.jdbc.Driver";
        String dbURL = "jdbc:mysql://localhost:3306/jsp41";
        String dbUser = "jsp41";
        String dbPassword = "poiu0987";

        Class.forName(driverName);
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        recommendPstmt = conn.prepareStatement(recommendSql);
        recommendPstmt.setInt(1, postID);
        recommendPstmt.setString(2, userID);
        recommendRs = recommendPstmt.executeQuery();
        if (recommendRs.next()) {
            isRecommended = true;
        }

        // 추천 수 가져오기
        String recommendCountSql = "SELECT COUNT(*) AS count FROM Recommend WHERE POST_code = ?";
        PreparedStatement recommendCountPstmt = conn.prepareStatement(recommendCountSql);
        recommendCountPstmt.setInt(1, postID);
        ResultSet recommendCountRs = recommendCountPstmt.executeQuery();
        if (recommendCountRs.next()) {
            recommendCount = recommendCountRs.getInt("count");
        }
    } catch (Exception e) {
        out.println("MySQL 데이터베이스 처리에 문제가 발생했습니다.<hr>");
        out.println(e.toString());
        e.printStackTrace();
    } finally {
        if (recommendPstmt != null) {
            recommendPstmt.close();
        }
        if (recommendRs != null) {
            recommendRs.close();
        }
    }

    PreparedStatement postPstmt = null;
    ResultSet postRs = null;
    PreparedStatement commentPstmt = null;
    ResultSet commentRs = null;
    PreparedStatement boardPstmt = null;
    ResultSet boardRs = null;
    try {
        String driverName = "com.mysql.jdbc.Driver";
        String dbURL = "jdbc:mysql://localhost:3306/jsp41";
        String dbUser = "jsp41";
        String dbPassword = "poiu0987";

        Class.forName(driverName);
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        String postSql = "SELECT * FROM Post WHERE POST_code = ?";
        postPstmt = conn.prepareStatement(postSql);
        postPstmt.setInt(1, postID);
        postRs = postPstmt.executeQuery();


        String boardSql = "SELECT * FROM Board";
        boardPstmt = conn.prepareStatement(boardSql);
        boardRs = boardPstmt.executeQuery();

        if (postRs.next()) {
            String title = postRs.getString("Title");
            String content = postRs.getString("Content");
            String writer = postRs.getString("User_ID");
            String date = postRs.getString("C_Date");
            String modifiedDate = postRs.getString("M_Date");
            int viewCount = postRs.getInt("ViewCount");
            int boardID = postRs.getInt("Board_ID");

            // 작성자의 닉네임 가져오기
            String writerNickName = null;
            String writerSql = "SELECT NickName FROM User WHERE User_ID = ?";
            PreparedStatement writerPstmt = conn.prepareStatement(writerSql);
            writerPstmt.setString(1, writer);
            ResultSet writerRs = writerPstmt.executeQuery();
            if (writerRs.next()) {
                writerNickName = writerRs.getString("NickName");
            }

%>
<!-- 네비게이션 바 -->
<nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
    <div class="container-fluid">
        <a class="navbar-brand" href="main.jsp">Novel AI</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ml-auto">
                <% if (userID != null) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <%= userNickName %>
                        </a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" href="logoutAction.jsp">로그아웃</a>
                            <a class="dropdown-item" href="updateUser.jsp">회원 정보 수정</a>
                            <a class="dropdown-item" href="myPosts.jsp?User_ID=<%= userID %>">My Post</a>

                        </div>
                    </li>
                <% } else { %>
                    <li class="nav-item">
                        <a class="nav-link" href="login.jsp">로그인</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="join.jsp">회원가입</a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<div class="container">
    <div class="panel panel-body">  
        <div class="panel-title">
            <h4 class=""><%= title %></h4>
        </div>
        <div style="border: 2px solid #8d8d8d; padding: 4px; background-color:#f8f9fa;">
            <div class="post-font" style="padding: 10px;">
                <p>작성자: <%= writerNickName %></p>
                <p>작성일: <%= date %></p>
                <% if (modifiedDate != null) { %>
                    <p>수정일: <%= modifiedDate %></p>
                <% } %>
                <p>조회수: <%= viewCount %></p>
                <p>추천수: <%= recommendCount %></p>
            </div>
            <div class="panel-body" style="padding: 10px;">
                <p style="font-size: 20px;"><%= content %></p>
            </div>
        </div>
        <% 
        if (userID != null && !userID.equals(writer)) { 
            String followCheckSql = "SELECT * FROM Follow WHERE Follower = ? AND Writer = ?";
            PreparedStatement followCheckPstmt = conn.prepareStatement(followCheckSql);
            followCheckPstmt.setString(1, userID);
            followCheckPstmt.setString(2, writer);
            ResultSet followCheckRs = followCheckPstmt.executeQuery();
            if (followCheckRs.next()) {
                // 이미 팔로우 중인 경우
    %>
                <a href="unfollowAction.jsp?followedID=<%= writer %>" class="btn btn-primary">언팔로우</a>
    <% } else { %>
                <a href="followAction.jsp?followedID=<%= writer %>" class="btn btn-primary">팔로우</a>
    <% } 
        } %>
        <% if (userID != null && !userID.equals(writer)) { %> <!-- 추천 버튼 -->
            <% if (isRecommended) { %>
                <a href="recommendAction.jsp?postID=<%= postID %>&cancel=true" class="btn btn-primary">추천 취소</a>
            <% } else { %>
                <a href="recommendAction.jsp?postID=<%= postID %>" class="btn btn-primary">추천</a>
            <% } %>
        <% } %>
    </div>

    <h4 class="post-font" style="padding-top:20px;">댓글</h4>
    <%
        String commentSql = "SELECT * FROM Comment WHERE POST_code = ?";
        commentPstmt = conn.prepareStatement(commentSql);
        commentPstmt.setInt(1, postID);
        commentRs = commentPstmt.executeQuery();

        while (commentRs.next()) {
            String commentContent = commentRs.getString("COM_con");
            String commentWriter = commentRs.getString("User_ID");
            String commentDate = commentRs.getString("COM_date");
            String commentModifiedDate = commentRs.getString("COM_mdd");

            // 작성자의 닉네임 가져오기
            String commentWriterNickName = null;
            String commentWriterSql = "SELECT NickName FROM User WHERE User_ID = ?";
            PreparedStatement commentWriterPstmt = conn.prepareStatement(commentWriterSql);
            commentWriterPstmt.setString(1, commentWriter);
            ResultSet commentWriterRs = commentWriterPstmt.executeQuery();
            if (commentWriterRs.next()) {
                commentWriterNickName = commentWriterRs.getString("NickName");
            }
    %>
            <div class="panel panel-default" style="border: 1px solid #8d8d8d; padding: 20px; margin-top: 20px; background-color:#f8f9fa;">
                <div class="panel-body">
                    <p style="font-size: 20px;"><%= commentContent %></p>
                </div>
                <div class="post-font" style="font-size:12px;">
                    <p>작성자: <%= commentWriterNickName %></p>
                </div>
                <div class="post-font" style="font-size:12px;">
                    <p>작성일: <%= commentDate %></p>
                    <% if (commentModifiedDate != null) { %>
                        <p>수정일: <%= commentModifiedDate %></p>
                    <% } %>
                    <% if ((userID != null && userID.equals(commentWriter))||(userAdmin != null && userAdmin.equals("1"))) { %>
                        <a href="updateComment.jsp?commentID=<%= commentRs.getInt("COM_code") %>" class="btn btn-primary btn-sm" style="font-size: 3px;">수정</a>
                    <a href="deleteCommentAction.jsp?commentID=<%= commentRs.getInt("COM_code") %> " class="btn btn-primary btn-sm" style="font-size: 3px;">삭제</a>
                    <% } %>
                </div>
            </div>
    <% } %>

    <% if (userID != null) { %>
        <div class="panel panel-default ">
            <div class="panel-body">
                <form action="commentAction.jsp" method="POST">
                    <input type="hidden" name="postID" value="<%= postID %>">
                    <div class="form-group">
                        <label for="commentContent" class="post-font" style="padding-top: 20px;">댓글 작성</label>
                        <textarea class="form-control" id="commentContent" name="commentContent" rows="3"></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">작성</button>
                </form>
            </div>
        </div>
    <% } %>

    <% if (boardRs.next()) { %>
        <a href="bbs.jsp?boardID=<%= postRs.getInt("Board_ID") %>" class="btn btn-primary">목록</a>
    <% } %>
    <% if (userID != null && userID.equals(writer)) { %>
        <a href="update.jsp?postID=<%= postID %>&boardID=<%= boardRs.getString("Board_ID") %>" class="btn btn-primary">수정</a>
        <a href="deleteAction.jsp?postID=<%= postID %>&boardID=<%= boardRs.getString("Board_ID") %>" class="btn btn-primary">삭제</a>
    <% } %>
</div>

<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="js/bootstrap.js"></script>
<% 
    } 
    else {
        out.println("<div class=\"container\">");
        out.println("<p>유효하지 않은 글입니다.</p>");
        if (boardRs.next()) {
            out.println("<a href=\"bbs.jsp?boardID=" + boardRs.getString("Board_ID") + "\" class=\"btn btn-primary\">목록</a>");
        }
        out.println("</div>");
    }
} catch (Exception e) {
    out.println("MySQL 데이터베이스 처리에 문제가 발생했습니다.<hr>");
    out.println(e.toString());
    e.printStackTrace();
} finally {
    if (postPstmt != null) {
        postPstmt.close();
    }
    if (postRs != null) {
        postRs.close();
    }
    if (commentPstmt != null) {
        commentPstmt.close();
    }
    if (commentRs != null) {
        commentRs.close();
    }
    if (conn != null) {
        conn.close();
    }
}
%>
</body>
</html>
