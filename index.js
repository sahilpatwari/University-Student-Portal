import express from "express";
import { dirname } from "path";
import { fileURLToPath } from "url";
import mysql from "mysql2/promise";
import bodyParser from "body-parser";
import env from "dotenv";
const __dirname = dirname(fileURLToPath(import.meta.url));
const app = express();
const port = 3000;
env.config();

const pool = mysql.createPool({
  host:process.env.MYSQL_HOST,
    user:process.env.MYSQL_USER,
    password:process.env.MYSQL_PASSWORD,
    database:process.env.MYSQL_DATABASE,
    waitForConnections: true,
    connectionLimit: 10,
    maxIdle: 10, // max idle connections, the default value is the same as `connectionLimit`
    idleTimeout: 60000, // idle connections timeout, in milliseconds, the default value 60000
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
});
pool.getConnection((err, connection) => {
  if (err) {
    if (err.code === "ER_CON_COUNT_ERROR") {
      console.error("Too many connections!");
    } else {
      console.error("Database error:", err);
    }
    return;
  }

  connection.release();
});
let s_id = "",
  first = "";
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"));
app.use("/styles", express.static("public/styles"));

app.get("/", (req, res) => {
  res.sendFile(__dirname + "/public/index.html");
});
app.get("/student", (req, res) => {
  res.render("login.ejs", {
    WrongId: " ",
    Id: "Student ID",
    route: "student",
    route1: "Student Login",
  });
});
app.get("/admin", (req, res) => {
  res.render("login.ejs", {
    WrongId: " ",
    Id: "Admin ID",
    route: "admin",
    route1: "Admin Login",
  });
});

// Add CGPA calculation endpoint
app.post("/calculate-cgpa", async (req, res) => {
  try {
    const studentId = req.body.studentId || s_id;
    if (!studentId) {
      return res.status(400).json({ error: "Student ID is required" });
    }

    // Use the stored procedure to calculate CGPA
    const [result] = await pool.query("CALL CalculateAndUpdateCGPA(?)", [
      studentId.toUpperCase(),
    ]);

    res.json({ message: "CGPA calculated successfully", result: result[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to calculate CGPA" });
  }
});

app.post("/student", async (req, res) => {
  s_id = req.body.studentId.trim();
  try {
    console.log(s_id);
    const [result] = await pool.query(
      "SELECT `Student_ID` from `student` where `Student_ID`=?;",
      [s_id.toUpperCase()]
    );
    if (result.length === 0) {
      res.render("login.ejs", {
        WrongId: "Wrong Student ID entered Please re-enter your Student ID.",
        Id: "Student ID",
        route: "student",
        route1: "Student Login",
      });
    } else {
      const [f_name] = await pool.query(
        "SELECT `First_Name` from `student` where `Student_ID`=?;",
        [s_id.toUpperCase()]
      );
      first = f_name[0].First_Name;
      res.render("student_portal.ejs", {
        F_Name: first,
      });
    }
  } catch (err) {
    console.log(err);
  }
});
app.get("/semester_c", (req, res) => {
  res.render("semester/semester_c.ejs", {
    F_Name: first,
  });
});
var semester = "";
app.post("/semester_c", (req, res) => {
  semester = req.body.semester_course.trim();
  res.redirect("/student_courses");
});
app.get("/student_courses", async (req, res) => {
  try {
    const [c] = await pool.query(
      "SELECT DISTINCT(Courses.Course_ID),Course_Name,Credits from (Courses INNER JOIN  Enrollment on Courses.Course_ID=Enrollment.Course_ID)   where Semester=? AND Student_ID=?;",
      [semester.toUpperCase(), s_id.toUpperCase()]
    );
    console.log(c);
    res.render("semester/display/student_courses.ejs", {
      F_Name: first,
      courses: c,
    });
  } catch (err) {
    console.log(err);
  }
});
app.get("/semester_g", (req, res) => {
  res.render("semester/semester_g.ejs", {
    F_Name: first,
  });
});
app.post("/semester_g", (req, res) => {
  semester = req.body.semester_grade.trim();
  res.redirect("/student_grades");
});
app.get("/student_grades", async (req, res) => {
  try {
    const [g] = await pool.query(
      "SELECT DISTINCT(Courses.Course_ID),Course_Name,Credits,Grade from (Courses INNER JOIN  Enrollment on Courses.Course_ID=Enrollment.Course_ID)   where Semester=? AND Student_ID=?;",
      [semester.toUpperCase(), s_id.toUpperCase()]
    );
    console.log(g);
    res.render("semester/display/student_grades.ejs", {
      F_Name: first,
      grades: g,
    });
  } catch (err) {
    console.log(err);
  }
});
app.get("/semester_a", (req, res) => {
  res.render("semester/semester_a.ejs", {
    F_Name: first,
  });
});
app.post("/semester_a", (req, res) => {
  semester = req.body.semester_attendance.trim();
  res.redirect("/student_attendance");
});
app.get("/student_attendance", async (req, res) => {
  try {
    const [a] = await pool.query(
      "SELECT DISTINCT(Courses.Course_ID),Course_Name,Credits,Total_Classes_Present,Total_Classes_Absent,Total_Classes_Held,Attendance_Percentage from (Courses INNER JOIN  Attendance on Courses.Course_ID=Attendance.Course_ID)   where Semester=? AND Student_ID=?;",
      [semester.toUpperCase(), s_id.toUpperCase()]
    );
    console.log(a);
    res.render("semester/display/student_attendance.ejs", {
      F_Name: first,
      attended: a,
    });
  } catch (err) {
    console.log(err);
  }
});
app.get("/student_details", async (req, res) => {
  const [d] = await pool.query("SELECT * from `student` where `Student_ID`=?", [
    s_id.toUpperCase(),
  ]);
  console.log(d);
  res.render("semester/display/student_details.ejs", {
    F_Name: first,
    details: d,
  });
});

app.post("/admin", async (req, res) => {
  const a_id = req.body.adminId.trim();
  if (a_id !== "Admin123") {
    res.render("login.ejs", {
      WrongId: "Wrong Admin ID entered.",
      Id: "Admin ID",
      route: "admin",
      route1: "Admin Login",
    });
  } else {
    res.render("partials/admin_header.ejs");
  }
});
app.get("/add", (req, res) => {
  res.render("admin_display/add.ejs");
});
app.get("/add_course", (req, res) => {
  res.render("admin_display/display/add/add_courses.ejs", {
    Query1: "",
  });
});
app.post("/add_course", async (req, res) => {
  try {
    const { course_id, course_name, credits, dept_id } = req.body;
    const [result] = await pool.query(
      "INSERT INTO Courses(Course_ID,Course_Name,Credits,Department_ID) VALUES(?,?,?,?)",
      [course_id, course_name, credits, dept_id]
    );
    res.render("admin_display/display/add/add_courses.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/add/add_courses.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/assign_course", (req, res) => {
  res.render("admin_display/display/add/assign_courses.ejs", {
    Query1: "",
  });
});
app.post("/assign_course", async (req, res) => {
  try {
    const { course_id, student_id, sem } = req.body;
    const [result] = await pool.query(
      "INSERT INTO Enrollment(Course_ID,Student_ID,Semester) VALUES(?,?,?)",
      [course_id, student_id, sem]
    );
    const [result1] = await pool.query(
      "INSERT INTO Attendance(Course_ID,Student_ID,Semester) VALUES(?,?,?)",
      [course_id, student_id, sem]
    );
    res.render("admin_display/display/add/assign_courses.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/add/assign_courses.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/add_student", (req, res) => {
  res.render("admin_display/display/add/add_student.ejs", {
    Query1: "",
  });
});
app.post("/add_student", async (req, res) => {
  try {
    const { student_id, first_name, last_name, DOB1, Year, dept_id } = req.body;
    const [result] = await pool.query(
      "INSERT INTO Student(Student_ID,First_Name,Last_Name,Date_OF_Birth,Year,Department_ID) VALUES(?,?,?,?,?,?)",
      [student_id, first_name, last_name, DOB1, Year, dept_id]
    );
    res.render("admin_display/display/add/add_student.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/add/add_student.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/delete", (req, res) => {
  res.render("admin_display/delete.ejs");
});
app.get("/remove_student", (req, res) => {
  res.render("admin_display/display/delete/remove_student.ejs", {
    Query1: "",
  });
});
app.post("/remove_student", async (req, res) => {
  try {
    const { student_id } = req.body;
    const [result] = await pool.query(
      "DELETE FROM Enrollment where Student_ID=?",
      [student_id.toUpperCase()]
    );
    const [result1] = await pool.query(
      "DELETE FROM Attendance where Student_ID=?",
      [student_id.toUpperCase()]
    );
    const [result2] = await pool.query(
      "DELETE FROM Student where Student_ID=?",
      [student_id.toUpperCase()]
    );
    res.render("admin_display/display/delete/remove_student.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/delete/remove_student.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/remove_course", (req, res) => {
  res.render("admin_display/display/delete/remove_course.ejs", {
    Query1: "",
  });
});
app.post("/remove_course", async (req, res) => {
  try {
    const { course_id } = req.body;
    const [result] = await pool.query(
      "DELETE FROM Enrollment where Course_ID=?",
      [course_id.toUpperCase()]
    );
    const [result1] = await pool.query(
      "DELETE FROM Attendance where Course_ID=?",
      [course_id.toUpperCase()]
    );
    const [result2] = await pool.query(
      "DELETE FROM courses where Course_ID=?",
      [course_id.toUpperCase()]
    );
    res.render("admin_display/display/delete/remove_course.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/delete/remove_course.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/update", (req, res) => {
  res.render("admin_display/update.ejs");
});
app.get("/update_course", (req, res) => {
  res.render("admin_display/display/update/update_course.ejs", {
    Query1: "",
  });
});
app.post("/update_course", async (req, res) => {
  try {
    const { course_id, course_name, credits, dept_id } = req.body;
    var updateData = {};
    if (course_name) updateData.Course_Name = course_name;
    if (credits) updateData.Credits = credits;
    if (dept_id) updateData.Department_ID = dept_id;
    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map((field) => `${field} = ?`).join(", ");
    const sql = `UPDATE Courses SET ${setClause} WHERE Course_ID = ?`;

    const [result] = await pool.execute(sql, [...values, course_id]);
    res.render("admin_display/display/update/update_course.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/update/update_course.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/update_student", (req, res) => {
  res.render("admin_display/display/update/update_student.ejs", {
    Query1: "",
  });
});
app.post("/update_student", async (req, res) => {
  try {
    const { student_id, first_name, last_name, DOB1, Year, dept_id } = req.body;
    var updateData = {};
    if (first_name) updateData.First_Name = first_name;
    if (last_name) updateData.Last_Name = last_name;
    if (DOB1) updateData.Date_OF_Birth = DOB1;
    if (Year) updateData.Year = Year;
    if (dept_id) updateData.Department_ID = dept_id;
    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map((field) => `${field} = ?`).join(", ");
    const sql = `UPDATE Student SET ${setClause} WHERE Student_ID = ?`;

    const [result] = await pool.execute(sql, [...values, student_id]);
    res.render("admin_display/display/update/update_course.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/update/update_course.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/update_grade", (req, res) => {
  res.render("admin_display/display/update/update_grade.ejs", {
    Query1: "",
  });
});

app.post("/update_grade", async (req, res) => {
  try {
    const { course_id, student_id, sem, grade } = req.body;
    const [result] = await pool.query(
      "UPDATE Enrollment SET Grade=? where Student_ID=? AND Course_ID=? AND Semester=?",
      [grade, student_id, course_id, sem]
    );
    res.render("admin_display/display/update/update_grade.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/update/update_grade.ejs", {
      Query1: "Query Failed",
    });
  }
});
app.get("/update_attendance", (req, res) => {
  res.render("admin_display/display/update/update_attendance.ejs", {
    Query1: "",
  });
});
app.post("/update_attendance", async (req, res) => {
  try {
    const { course_id, student_id, sem, present, absent, Total, percent } =
      req.body;
    var updateData = {};
    if (present) updateData.Total_Classes_Present = present;
    if (absent) updateData.Total_Classes_Absent = absent;
    if (Total) updateData.Total_Classes_Held = Total;
    if (percent) updateData.Attendance_Percentage = percent;
    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map((field) => `${field} = ?`).join(", ");
    const sql = `UPDATE Attendance SET ${setClause} WHERE Student_ID = ? AND Course_ID=? AND Semester=?;`;

    const [result] = await pool.execute(sql, [
      ...values,
      student_id,
      course_id,
      sem,
    ]);
    res.render("admin_display/display/update/update_attendance.ejs", {
      Query1: "Query Executed Successfully",
    });
  } catch (err) {
    console.log(err);
    res.render("admin_display/display/update/update_attendance.ejs", {
      Query1: "Query Failed",
    });
  }
});
// Add to index.js
// Add dashboard data route
app.get("/dashboard-data", async (req, res) => {
  try {
    const studentId = req.query.studentId || s_id;
    if (!studentId) {
      return res.status(400).json({ error: "Student ID is required" });
    }

    // Fetch course count
    const [courseCount] = await pool.query(
      "SELECT COUNT(*) as count FROM Enrollment WHERE Student_ID = ?",
      [studentId.toUpperCase()]
    );

    // Fetch average attendance
    const [avgAttendance] = await pool.query(
      "SELECT AVG(Attendance_Percentage) as avg FROM Attendance WHERE Student_ID = ?",
      [studentId.toUpperCase()]
    );

    // Fetch CGPA
    const [cgpa] = await pool.query(
      "SELECT CGPA FROM Student WHERE Student_ID = ?",
      [studentId.toUpperCase()]
    );

    res.json({
      courseCount: courseCount[0].count,
      attendance: avgAttendance[0].avg || 0,
      cgpa: cgpa[0].CGPA || 0,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch dashboard data" });
  }
});
app.listen(port, () => {
  console.log("Server is running on port ", port);
});
