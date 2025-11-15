const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Flutter 빌드 폴더 경로 설정 (Node.js 프로젝트 위치에 따라 경로 조정 필요)
const flutterBuildPath = path.join(__dirname, 'build', 'web');

// 정적 파일 제공
app.use(express.static(flutterBuildPath));

// JSON Body 파싱
app.use(express.json());

/// 데이터 베이스
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: '1234', // 본인 MySQL 비밀번호로 변경
    database: 'study_together'
};

const dbPool = mysql.createPool(dbConfig);

async function initDatabase() {
    try {
        // 1. MySQL 서버 연결 (DB 없이)
        const connection = await mysql.createConnection({
            host: dbConfig.host,
            user: dbConfig.user,
            password: dbConfig.password
        });

        // 2. 데이터베이스 생성
        await connection.query(`CREATE DATABASE IF NOT EXISTS ${dbConfig.database}`);
        await connection.query(`USE ${dbConfig.database}`);
        console.log(`Database '${dbConfig.database}' is ready.`);

        // 3. 사용자 테이블 생성
        await connection.query(`
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(50) NOT NULL UNIQUE,
                auth_code VARCHAR(100) NOT NULL
            )
        `);
        console.log('Table "users" is ready.');

        // 4. 스터디 테이블 생성
        await connection.query(`
            CREATE TABLE IF NOT EXISTS studies (
                id INT AUTO_INCREMENT PRIMARY KEY,
                study_name VARCHAR(100) NOT NULL UNIQUE,
                target VARCHAR(100),
                weekday VARCHAR(20),
                start_time VARCHAR(20),
                end_time VARCHAR(20),
                location VARCHAR(200),
                requirements TEXT
            )
        `);
        console.log('Table "studies" is ready.');

        // 5. 스터디-사용자 연결 테이블 생성 (다대다)
        await connection.query(`
            CREATE TABLE IF NOT EXISTS study_participants (
                study_name VARCHAR(100) NOT NULL,
                username VARCHAR(50) NOT NULL,
                PRIMARY KEY (study_name, username),
                FOREIGN KEY (study_name) REFERENCES studies(study_name) ON DELETE CASCADE,
                FOREIGN KEY (username) REFERENCES users(username) ON DELETE CASCADE
            )
        `);
        console.log('Table "study_participants" is ready.');

        await connection.end();
        console.log('Database initialization completed!');
    } catch (err) {
        console.error('MySQL initialization error:', err);
        process.exit(1); // DB 초기화 실패 시 종료
    }
}

///
/// api 모음들

// 회원 가입
app.post('/user/create', async (req, res) => {
    const { username, auth_code } = req.body;

    // 유효성 체크
    if (!username || !auth_code) {
        return res.status(400).json({ error: 'username과 auth_code가 필요합니다.' });
    }

    try {
        const [result] = await dbPool.execute(
            'INSERT INTO users (username, auth_code) VALUES (?, ?)',
            [username, auth_code]
        );

        // 삽입된 ID 반환
        res.status(200).json({
            id: result.insertId,
            username,
            auth_code
        });
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ error: '이미 존재하는 username입니다.' });
        }
        console.error(err);
        res.status(500).json({ error: 'DB 삽입 중 오류 발생' });
    }
});

// 사용자 로그인
app.post('/user/login', async (req, res) => {
    const { username, auth_code } = req.body;
    console.log("로그인 시도");
    // 요청값 유효성 체크
    if (!username || !auth_code) {
        return res.status(400).json({ error: 'username과 auth_code가 필요합니다.' });
    }

    try {
        // DB에서 username + auth_code 조회
        const [rows] = await dbPool.execute(
            'SELECT id FROM users WHERE username = ? AND auth_code = ?',
            [username, auth_code]
        );

        if (rows.length > 0) {
            // 존재함 → 200 OK
            res.status(200).json({ message: '사용자 존재' });
        } else {
            // 존재하지 않음 → 400
            res.status(400).json({ error: '사용자를 찾을 수 없음' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'DB 조회 중 오류 발생' });
    }
});

// 스터디 생성
app.post('/study/create', async (req, res) => {
    const {
        study_name,
        target,
        weekday,
        start_time,
        end_time,
        location,
        requirements
    } = req.body;

    // 입력값 검증
    if (!study_name || !weekday || !start_time || !end_time || !location) {
        return res.status(400).json({
            error: "study_name, weekday, start_time, end_time, location 은 필수입니다."
        });
    }

    try {
        const sql = `
            INSERT INTO studies 
            (study_name, target, weekday, start_time, end_time, location, requirements)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `;

        const values = [
            study_name,
            target || null,
            weekday,
            start_time,
            end_time,
            location,
            requirements || null
        ];

        const [result] = await dbPool.execute(sql, values);

        res.status(200).json({
            message: "스터디 생성 성공",
            study_id: result.insertId,
            data: {
                study_name,
                target,
                weekday,
                start_time,
                end_time,
                location,
                requirements
            }
        });
    } catch (err) {
        console.error("스터디 생성 에러:", err);
        res.status(500).json({ error: "동일한 스터디 이름이 이미 존재합니다." });
    }
});

// 모든 스터디 조회
app.get('/study/list', async (req, res) => {
    try {
        const [rows] = await dbPool.execute("SELECT * FROM studies");

        return res.status(200).json({
            count: rows.length,
            studies: rows
        });
    } catch (err) {
        console.error("스터디 조회 중 오류:", err);
        return res.status(500).json({ error: "DB 조회 중 오류 발생" });
    }
});

// 스터디 참가
app.post('/study/join', async (req, res) => {
    const { study_name, username } = req.body;

    if (!study_name || !username) {
        return res.status(400).json({ error: "study_name과 username이 필요합니다." });
    }

    try {
        const [existing] = await dbPool.execute(
            "SELECT * FROM study_participants WHERE study_name = ? AND username = ?",
            [study_name, username]
        );

        if (existing.length > 0) {
            return res.status(400).json({ error: "이미 참여한 스터디입니다." });
        }

        await dbPool.execute(
            "INSERT INTO study_participants (study_name, username) VALUES (?, ?)",
            [study_name, username]
        );

        res.status(200).json({ message: "스터디 참여 완료" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "DB 삽입 중 오류 발생" });
    }
});


// 참여한 모든 스터디 조회
app.get('/user/studies', async (req, res) => {
    const { username } = req.query; // Query parameter로 받음

    if (!username) {
        return res.status(400).json({ error: "username이 필요합니다." });
    }

    try {
        const [rows] = await dbPool.execute(`
            SELECT s.*
            FROM studies s
            JOIN study_participants sp ON s.study_name = sp.study_name
            WHERE sp.username = ?
        `, [username]);

        res.status(200).json({
            count: rows.length,
            studies: rows
        });
    } catch (err) {
        console.error("사용자 참여 스터디 조회 중 오류:", err);
        res.status(500).json({ error: "DB 조회 중 오류 발생" });
    }
});

// 스터디 탈퇴
app.delete('/study/leave', async (req, res) => {
    const { study_name, username } = req.body;

    // 필수값 체크
    if (!study_name || !username) {
        return res.status(400).json({ error: "study_name과 username이 필요합니다." });
    }

    try {
        // 해당 레코드 삭제
        const [result] = await dbPool.execute(
            "DELETE FROM study_participants WHERE study_name = ? AND username = ?",
            [study_name, username]
        );

        if (result.affectedRows === 0) {
            return res.status(400).json({ error: "참여 중인 스터디가 없습니다." });
        }

        res.status(200).json({ message: "스터디 탈퇴 완료" });
    } catch (err) {
        console.error("스터디 탈퇴 중 오류:", err);
        res.status(500).json({ error: "DB 삭제 중 오류 발생" });
    }
});

/// 유저 탈퇴
app.delete('/user/delete', async (req, res) => {
    const { username } = req.body;

    // 필수값 체크
    if (!username) {
        return res.status(400).json({ error: "username이 필요합니다." });
    }

    try {
        // 유저 삭제
        const [result] = await dbPool.execute(
            "DELETE FROM users WHERE username = ?",
            [username]
        );

        if (result.affectedRows === 0) {
            return res.status(400).json({ error: "해당 사용자가 존재하지 않습니다." });
        }

        res.status(200).json({ message: "유저 탈퇴 완료" });
    } catch (err) {
        console.error("유저 삭제 중 오류:", err);
        res.status(500).json({ error: "DB 삭제 중 오류 발생" });
    }
});

// 스터디 인원 수 체크 및 자동 삭제
app.post('/study/check_and_delete', async (req, res) => {
    const { study_name } = req.body;

    if (!study_name) {
        return res.status(400).json({ error: "study_name이 필요합니다." });
    }

    try {
        // 1. 참여자 수 조회
        const [countRows] = await dbPool.execute(
            "SELECT COUNT(*) AS count FROM study_participants WHERE study_name = ?",
            [study_name]
        );

        const participantCount = countRows[0].count;

        // 2. 참여자 0명일 경우 스터디 삭제
        if (participantCount === 0) {
            const [deleteResult] = await dbPool.execute(
                "DELETE FROM studies WHERE study_name = ?",
                [study_name]
            );

            if (deleteResult.affectedRows > 0) {
                return res.status(200).json({
                    message: "스터디가 참여자 0명으로 삭제되었습니다.",
                    deleted: true
                });
            } else {
                return res.status(400).json({
                    error: "스터디를 삭제할 수 없습니다.",
                    deleted: false
                });
            }
        }

        // 참여자가 남아있음 → 삭제하지 않음
        return res.status(200).json({
            message: "아직 참여자가 남아 있어 스터디는 유지됩니다.",
            deleted: false
        });

    } catch (err) {
        console.error("스터디 자동 삭제 체크 오류:", err);
        res.status(500).json({ error: "서버 오류 발생" });
    }
});

///
// 모든 요청에 대해 index.html 제공 (Flutter 라우팅 처리용)
app.get('/', (req, res) => {
    res.sendFile(path.join(flutterBuildPath, 'index.html'));
});

app.get('/hello', (req, res) => {
    res.json({
        message: 'Hello from Node.js!'
    });
}); 

initDatabase().then(() => {
    app.listen(PORT, () => {
        console.log(`Server is running on http://localhost:${PORT}`);
    });
});
