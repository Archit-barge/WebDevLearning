-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: eduverse
-- ------------------------------------------------------
-- Server version	9.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `address` text,
  `permissions` text,
  PRIMARY KEY (`admin_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,6,'Arc','Admin','1234567890','Admin Address',NULL),(2,7,'System','Administrator','0987654321','Server Room',NULL),(9,70,'Admin','One','9988700001','Mumbai',NULL),(10,71,'Admin','Two','9988700002','Pune',NULL),(11,72,'Admin','DupA','9988700003','Nashik',NULL);
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `class_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (15,'Today','hxixhw','2026-01-06 08:57:07',NULL),(27,'jj','hj','2026-02-27 15:57:44',14),(28,'hyujil;','srtykl;\'','2026-02-28 03:53:18',14),(29,'hyujil;','srtykl;\'','2026-02-28 03:53:47',8),(30,'srg','rftyui','2026-02-28 06:25:57',14),(31,'hi','DD','2026-02-28 06:33:34',8),(32,'HII','SJJS','2026-02-28 07:06:49',14),(33,'SS','SS','2026-02-28 07:07:30',14),(34,'ygu','hyguhij','2026-02-28 07:14:01',14),(35,'Hii','wgugd','2026-03-11 01:57:35',14),(36,'ygh','gcvhbn','2026-03-13 16:13:23',14),(37,'ygh','gcvhbn','2026-03-13 16:13:25',14);
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `attendance_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int DEFAULT NULL,
  `date` date NOT NULL,
  `status` enum('present','absent') NOT NULL,
  `marked_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attendance_id`),
  KEY `fk_att_student` (`student_id`),
  KEY `fk_att_class` (`class_id`),
  KEY `fk_att_user` (`marked_by`),
  CONSTRAINT `fk_att_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_att_user` FOREIGN KEY (`marked_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch`
--

DROP TABLE IF EXISTS `branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch`
--

LOCK TABLES `branch` WRITE;
/*!40000 ALTER TABLE `branch` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class_subjects`
--

DROP TABLE IF EXISTS `class_subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subjects` (
  `id` int NOT NULL AUTO_INCREMENT,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `teacher_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `class_id` (`class_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `class_subjects_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `class_subjects_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class_subjects`
--

LOCK TABLES `class_subjects` WRITE;
/*!40000 ALTER TABLE `class_subjects` DISABLE KEYS */;
INSERT INTO `class_subjects` VALUES (4,14,1,5),(5,14,2,6),(6,14,6,7),(7,14,7,9),(8,14,3,10),(9,14,5,11),(10,14,4,8),(11,8,1,5),(12,9,2,12),(13,9,1,5);
/*!40000 ALTER TABLE `class_subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class_whatsapp_group`
--

DROP TABLE IF EXISTS `class_whatsapp_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_whatsapp_group` (
  `class_id` int NOT NULL,
  `whatsapp_link` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`class_id`),
  CONSTRAINT `fk_whatsapp_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class_whatsapp_group`
--

LOCK TABLES `class_whatsapp_group` WRITE;
/*!40000 ALTER TABLE `class_whatsapp_group` DISABLE KEYS */;
INSERT INTO `class_whatsapp_group` VALUES (8,'https://chat.whatsapp.com/JDJTTtWyKpjCvm0OGVGkWv?mode=gi_t'),(9,'https://chat.whatsapp.com/HM81TBZplTZ9HxGhfoAoXB?mode=gi_t'),(14,'https://chat.whatsapp.com/JlmCDcHvIp93FwSegUkj0u?mode=gi_c');
/*!40000 ALTER TABLE `class_whatsapp_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `classes` (
  `class_id` int NOT NULL AUTO_INCREMENT,
  `class_name` varchar(50) NOT NULL,
  `section` varchar(10) DEFAULT NULL,
  `teacher_id` int DEFAULT NULL,
  `academic_year` varchar(20) DEFAULT NULL,
  `max_students` int DEFAULT '40',
  PRIMARY KEY (`class_id`),
  UNIQUE KEY `uq_classes_teacher` (`teacher_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes`
--

LOCK TABLES `classes` WRITE;
/*!40000 ALTER TABLE `classes` DISABLE KEYS */;
INSERT INTO `classes` VALUES (8,'CM','1',NULL,NULL,70),(9,'CM','2',NULL,NULL,70),(14,'CM','3',9,NULL,100);
/*!40000 ALTER TABLE `classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `defaulters`
--

DROP TABLE IF EXISTS `defaulters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `defaulters` (
  `attendance_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `class_id` int NOT NULL,
  `date` date NOT NULL,
  `status` enum('present','absent') NOT NULL,
  PRIMARY KEY (`attendance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `defaulters`
--

LOCK TABLES `defaulters` WRITE;
/*!40000 ALTER TABLE `defaulters` DISABLE KEYS */;
/*!40000 ALTER TABLE `defaulters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `document_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `document_type` enum('SYLLABUS','NOTES','TIMETABLES') NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `original_file_name` varchar(255) DEFAULT NULL,
  `file_size` bigint NOT NULL,
  `file_extension` varchar(10) NOT NULL,
  `class_id` int DEFAULT NULL,
  `subject_id` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `upload_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`document_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (5,'djdkkkd','','NOTES','1772054368599_black book Foramt Dev Rai CFTC_BB.pdf','notes/1772054368599_black book Foramt Dev Rai CFTC_BB.pdf','black book Foramt Dev Rai CFTC_BB.pdf',6358453,'pdf',14,NULL,6,'2026-02-25 21:19:35'),(6,'qqqqqqqqqq','d','NOTES','1772056568155_prc16.docx','syllabus/1772056568155_prc16.docx','prc16.docx',473676,'docx',NULL,NULL,1,'2026-02-25 21:56:13'),(7,'abeee','','SYLLABUS','1772100896542_Green_Computing_Presentation.pptx','syllabus/1772100896542_Green_Computing_Presentation.pptx','Green_Computing_Presentation.pptx',38300,'pptx',8,NULL,6,'2026-02-26 10:14:59'),(8,'WhatsApp Image 2025-11-24 at 21.16.03_fa7c1228.jpg',NULL,'TIMETABLES','1772110673946_WhatsApp Image 2025-11-24 at 21.16.03_fa7c1228.jpg','timetables/1772110673946_WhatsApp Image 2025-11-24 at 21.16.03_fa7c1228.jpg','WhatsApp Image 2025-11-24 at 21.16.03_fa7c1228.jpg',100297,'jpg',8,NULL,1,'2026-02-26 12:58:02'),(10,'Man qb','','NOTES','1772140185814_MAN (315301)_CE6K_ Question Bank UT-1 with answer.pdf','notes/1772140185814_MAN (315301)_CE6K_ Question Bank UT-1 with answer.pdf','MAN (315301)_CE6K_ Question Bank UT-1 with answer.pdf',966451,'pdf',14,NULL,6,'2026-02-26 21:09:52'),(11,'Man qb','','NOTES','1772140187424_MAN (315301)_CE6K_ Question Bank UT-1 with answer.pdf','notes/1772140187424_MAN (315301)_CE6K_ Question Bank UT-1 with answer.pdf','MAN (315301)_CE6K_ Question Bank UT-1 with answer.pdf',966451,'pdf',14,NULL,6,'2026-02-26 21:09:53'),(13,'gggg','njk','SYLLABUS','1772200509232_Screenshot 2025-12-07 201626.png','syllabus/1772200509232_Screenshot 2025-12-07 201626.png','Screenshot 2025-12-07 201626.png',231815,'png',14,1,7,'2026-02-27 13:55:10'),(15,'TimeTable','TimeTable for CM3','TIMETABLES','1772252448671_TimeTable.jpeg','timetables/1772252448671_TimeTable.jpeg','TimeTable.jpeg',65722,'jpeg',14,NULL,7,'2026-02-28 04:20:51'),(17,'hiII','','SYLLABUS','1772260520722_MARKSHEET FIR.pdf','syllabus/1772260520722_MARKSHEET FIR.pdf','MARKSHEET FIR.pdf',653747,'pdf',14,5,6,'2026-02-28 06:35:24'),(18,'hiII','','SYLLABUS','1772260523959_MARKSHEET FIR.pdf','syllabus/1772260523959_MARKSHEET FIR.pdf','MARKSHEET FIR.pdf',653747,'pdf',14,5,6,'2026-02-28 06:35:27'),(19,'Application.jpg',NULL,'TIMETABLES','1772261762340_Application.jpg','timetables/1772261762340_Application.jpg','Application.jpg',2079805,'jpg',9,NULL,35,'2026-02-28 06:56:09'),(20,'hqidho','hhv','SYLLABUS','1772261808646_.ITR.pdf','syllabus/1772261808646_.ITR.pdf','.ITR.pdf',990967,'pdf',9,1,35,'2026-02-28 06:56:53'),(21,'D','','NOTES','1772262591012_Final Script Varaha.docx','notes/1772262591012_Final Script Varaha.docx','Final Script Varaha.docx',25703,'docx',14,3,6,'2026-02-28 07:09:52'),(22,'D','','NOTES','1772262592029_Final Script Varaha.docx','notes/1772262592029_Final Script Varaha.docx','Final Script Varaha.docx',25703,'docx',14,3,6,'2026-02-28 07:09:53'),(23,'Application.jpg',NULL,'TIMETABLES','1773194328932_Application.jpg','timetables/1773194328932_Application.jpg','Application.jpg',2079805,'jpg',14,NULL,35,'2026-03-11 01:59:03');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `event_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `description` text,
  `event_date` date DEFAULT NULL,
  `template_type` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exams`
--

DROP TABLE IF EXISTS `exams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exams` (
  `exam_id` int NOT NULL AUTO_INCREMENT,
  `exam_name` varchar(100) NOT NULL,
  `exam_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`exam_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exams`
--

LOCK TABLES `exams` WRITE;
/*!40000 ALTER TABLE `exams` DISABLE KEYS */;
INSERT INTO `exams` VALUES (1,'Unit Test 1',NULL,'2026-03-10 11:50:59'),(2,'Unit Test 2',NULL,'2026-03-10 11:50:59'),(3,'Practical Exam',NULL,'2026-03-10 11:50:59'),(4,'Final Internal',NULL,'2026-03-10 11:50:59');
/*!40000 ALTER TABLE `exams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `full_attendance`
--

DROP TABLE IF EXISTS `full_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `full_attendance` (
  `attendance_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `attendance_date` date NOT NULL,
  `session_type` varchar(20) NOT NULL,
  `time_slot` varchar(50) NOT NULL,
  `status` enum('present','absent') DEFAULT 'absent',
  `marked_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attendance_id`),
  UNIQUE KEY `unique_full_attendance` (`student_id`,`subject_id`,`attendance_date`,`time_slot`),
  KEY `fk_fullatt_class` (`class_id`),
  KEY `fk_fullatt_subject` (`subject_id`),
  KEY `fk_fullatt_teacher` (`marked_by`),
  CONSTRAINT `fk_fullatt_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_fullatt_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_fullatt_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_fullatt_teacher` FOREIGN KEY (`marked_by`) REFERENCES `teachers` (`teacher_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `full_attendance`
--

LOCK TABLES `full_attendance` WRITE;
/*!40000 ALTER TABLE `full_attendance` DISABLE KEYS */;
INSERT INTO `full_attendance` VALUES (1,1,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(2,2,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(3,3,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(4,4,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(5,5,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(6,6,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(7,7,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(8,8,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(9,9,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(10,10,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(11,11,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(12,12,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(13,13,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(14,14,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(15,15,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(16,16,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(17,17,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(18,19,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(19,20,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(20,22,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(21,23,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(22,24,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(23,25,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(24,26,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(25,46,14,1,'2026-03-13','theory','21:39-21:40','absent',5,'2026-03-13 16:10:12'),(26,1,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(27,2,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(28,3,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(29,4,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(30,5,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(31,6,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(32,7,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(33,8,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(34,9,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(35,10,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(36,11,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(37,12,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(38,13,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(39,14,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(40,15,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(41,16,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(42,17,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(43,19,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(44,20,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(45,22,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(46,23,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(47,24,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(48,25,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(49,26,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(50,46,14,1,'2026-03-12','theory','09:43-15:40','present',5,'2026-03-13 16:10:37'),(51,1,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(52,2,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(53,3,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(54,4,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(55,5,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(56,6,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(57,7,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(58,8,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(59,9,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(60,10,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(61,11,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(62,12,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(63,13,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(64,14,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(65,15,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(66,16,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(67,17,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(68,19,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(69,20,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(70,22,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(71,23,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(72,24,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(73,25,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(74,26,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24'),(75,46,14,1,'2026-03-01','practical','21:44-21:45','absent',5,'2026-03-13 16:11:24');
/*!40000 ALTER TABLE `full_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lecture_sessions`
--

DROP TABLE IF EXISTS `lecture_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lecture_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_code` varchar(20) DEFAULT NULL,
  `course_name` varchar(100) DEFAULT NULL,
  `year` varchar(20) DEFAULT NULL,
  `semester` varchar(20) DEFAULT NULL,
  `session_type` varchar(50) DEFAULT NULL,
  `session_date` date DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `classroom` varchar(50) DEFAULT NULL,
  `proposed_topic` text,
  `completed_topic` text,
  `syllabus_type` varchar(50) DEFAULT NULL,
  `completion_date` date DEFAULT NULL,
  `teaching_method` varchar(100) DEFAULT NULL,
  `teacher_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lecture_sessions`
--

LOCK TABLES `lecture_sessions` WRITE;
/*!40000 ALTER TABLE `lecture_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `lecture_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marks`
--

DROP TABLE IF EXISTS `marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `subject_name` varchar(100) DEFAULT NULL,
  `ut1` int DEFAULT NULL,
  `ut2` int DEFAULT NULL,
  `average` float DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sem1` int DEFAULT NULL,
  `sem2` int DEFAULT NULL,
  `sem_average` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_student_subject` (`student_id`,`subject_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_subject_id` (`subject_id`),
  CONSTRAINT `fk_mark_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_mark_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marks`
--

LOCK TABLES `marks` WRITE;
/*!40000 ALTER TABLE `marks` DISABLE KEYS */;
INSERT INTO `marks` VALUES (1,1,'Aryan','Gangarde',1,'DFH',30,30,30,'2026-03-13 11:33:36',19,1,10),(2,46,'Habib','Mansuri',1,'DFH',0,1,0.5,'2026-03-13 11:33:37',1,1,1),(3,4,'Rucha','Mhatre',1,'DFH',7,9,8,'2026-03-13 11:33:37',2,2,2),(4,5,'Aarya','Patil',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',9,9,9),(5,9,'Piyush','Dhumale',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(6,19,'Shridhar','Dalvi',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(7,20,'Roshan','Jadhav',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(8,24,'Aryan','Gaikwad',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(9,25,'Sakshant','Patil',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(10,26,'Viraj','Rajput',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(11,23,'Om','Darekar',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(12,22,'Omkar','Ghutukade',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(13,13,'Harshita','Mokashi',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(14,12,'Shreeya','Pandagale',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(15,15,'Vaishnavi','Sankpal',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(16,11,'Arya','',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(17,14,'Saanvi','Rajam',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(18,17,'Unnati','Khairnar',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(19,3,'Anish','Bhalerao',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(20,6,'Om','Jadhav',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(21,16,'Laksh','bhosle',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(22,8,'Piyush','Surve',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(23,7,'Atharva','Narwade',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(24,2,'Prajwal','Atkari',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(25,10,'Bhumika','Nawale',1,'DFH',NULL,NULL,NULL,'2026-03-13 11:33:37',NULL,NULL,NULL),(26,37,'Moin','Khan',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:20',30,30,30),(27,38,'Sadik','Khan',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(28,45,'Elon','Musk',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(29,41,'Sam','Altman',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(30,39,'Rehan','Shaikh',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(31,43,'Pooja','Hegde',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(32,44,'Anup','Patil',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(33,40,'Vedant','Patil',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(34,42,'Sheetal','Thakur',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL),(35,21,'Samarth','Gosavi',1,'DFH',NULL,NULL,NULL,'2026-03-13 15:22:22',NULL,NULL,NULL);
/*!40000 ALTER TABLE `marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `message` text,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,4,'New Timetable Uploaded','A new timetable has been uploaded for class 8',0,'2026-02-16 14:35:02');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parents`
--

DROP TABLE IF EXISTS `parents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parents` (
  `parent_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text,
  `relationship_to_student` enum('father','mother','guardian') DEFAULT NULL,
  `student_id` int DEFAULT NULL,
  PRIMARY KEY (`parent_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_parent_student` (`student_id`),
  CONSTRAINT `parents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parents`
--

LOCK TABLES `parents` WRITE;
/*!40000 ALTER TABLE `parents` DISABLE KEYS */;
INSERT INTO `parents` VALUES (1,2,'Parent','One','1122334455',NULL,'Home Address','father',NULL),(2,61,'Mahtre','Parents','9137295939','mahtre@gmail.com','BVIT','father',NULL);
/*!40000 ALTER TABLE `parents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `practical_marks`
--

DROP TABLE IF EXISTS `practical_marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practical_marks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `activity_name` varchar(100) NOT NULL,
  `practical_no` int NOT NULL,
  `marks` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_practical` (`student_id`,`class_id`,`subject_id`,`activity_name`,`practical_no`),
  UNIQUE KEY `unique_practical` (`student_id`,`class_id`,`subject_id`,`activity_name`,`practical_no`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practical_marks`
--

LOCK TABLES `practical_marks` WRITE;
/*!40000 ALTER TABLE `practical_marks` DISABLE KEYS */;
INSERT INTO `practical_marks` VALUES (1,1,14,1,'Assignment',1,2),(2,1,14,1,'Assignment',2,2),(3,1,14,1,'Assignment',3,2),(4,1,14,1,'Assignment',4,2),(5,1,14,1,'Assignment',5,2),(6,1,14,1,'Assignment',6,2),(7,1,14,1,'Assignment',7,1),(8,1,14,1,'Assignment',8,1),(9,1,14,1,'Assignment',9,1),(10,1,14,1,'Assignment',10,1),(11,1,14,1,'Assignment',11,1),(12,1,14,1,'Assignment',12,1);
/*!40000 ALTER TABLE `practical_marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `practicals`
--

DROP TABLE IF EXISTS `practicals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practicals` (
  `practical_id` int NOT NULL AUTO_INCREMENT,
  `subject_id` int NOT NULL,
  `exam_id` int DEFAULT NULL,
  `practical_no` int NOT NULL,
  `max_marks` int NOT NULL DEFAULT '10',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`practical_id`),
  KEY `subject_id` (`subject_id`),
  KEY `exam_id` (`exam_id`),
  CONSTRAINT `practicals_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  CONSTRAINT `practicals_ibfk_2` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practicals`
--

LOCK TABLES `practicals` WRITE;
/*!40000 ALTER TABLE `practicals` DISABLE KEYS */;
/*!40000 ALTER TABLE `practicals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_subscriptions`
--

DROP TABLE IF EXISTS `push_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_subscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `endpoint` text NOT NULL,
  `p256dh` text NOT NULL,
  `auth` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_subscriptions`
--

LOCK TABLES `push_subscriptions` WRITE;
/*!40000 ALTER TABLE `push_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `results` (
  `result_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `exam_name` varchar(100) DEFAULT NULL,
  `marks` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`result_id`),
  KEY `student_id` (`student_id`),
  KEY `class_id` (`class_id`),
  KEY `subject_id` (`subject_id`),
  CONSTRAINT `results_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `results_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `results_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `results`
--

LOCK TABLES `results` WRITE;
/*!40000 ALTER TABLE `results` DISABLE KEYS */;
INSERT INTO `results` VALUES (1,1,14,1,'Mid Term',78,'2026-03-02 18:43:47'),(2,2,14,1,'Mid Term',45,'2026-03-02 18:43:47'),(3,3,14,1,'Mid Term',32,'2026-03-02 18:43:47'),(4,4,14,1,'Mid Term',90,'2026-03-02 18:43:47'),(5,5,14,1,'Mid Term',67,'2026-03-02 18:43:47'),(6,6,14,1,'Mid Term',29,'2026-03-02 18:43:47');
/*!40000 ALTER TABLE `results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `semester_marks`
--

DROP TABLE IF EXISTS `semester_marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `semester_marks` (
  `sem_mark_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `class_id` int NOT NULL,
  `sem1` int DEFAULT NULL,
  `sem2` int DEFAULT NULL,
  `sem_average` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`sem_mark_id`),
  UNIQUE KEY `unique_sem_record` (`student_id`,`subject_id`),
  KEY `subject_id` (`subject_id`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `semester_marks_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `semester_marks_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  CONSTRAINT `semester_marks_ibfk_3` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `semester_marks`
--

LOCK TABLES `semester_marks` WRITE;
/*!40000 ALTER TABLE `semester_marks` DISABLE KEYS */;
/*!40000 ALTER TABLE `semester_marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_marks`
--

DROP TABLE IF EXISTS `student_marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_marks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `exam_id` int DEFAULT NULL,
  `component_type` varchar(20) NOT NULL,
  `component_id` int NOT NULL,
  `marks` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_student_component` (`student_id`,`subject_id`,`exam_id`,`component_type`,`component_id`),
  KEY `subject_id` (`subject_id`),
  KEY `exam_id` (`exam_id`),
  CONSTRAINT `student_marks_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `student_marks_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  CONSTRAINT `student_marks_ibfk_3` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_marks`
--

LOCK TABLES `student_marks` WRITE;
/*!40000 ALTER TABLE `student_marks` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_parents`
--

DROP TABLE IF EXISTS `student_parents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_parents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `parent_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_link` (`student_id`,`parent_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `student_parents_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `student_parents_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`parent_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_parents`
--

LOCK TABLES `student_parents` WRITE;
/*!40000 ALTER TABLE `student_parents` DISABLE KEYS */;
INSERT INTO `student_parents` VALUES (11,1,1),(12,21,1),(13,27,2);
/*!40000 ALTER TABLE `student_parents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `student_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `roll_number` varchar(20) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `address` text,
  `class_id` int DEFAULT NULL,
  `section` varchar(5) DEFAULT NULL,
  `admission_date` date DEFAULT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `roll_number` (`roll_number`),
  KEY `user_id` (`user_id`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `students_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (1,8,'3301','Aryan','Gangarde','2007-09-07','Male','9324644612','Amrut Kumbh C.H.S near mamta nursing home Kalyan(East)',14,NULL,'2026-02-07'),(2,9,'3357','Prajwal','Atkari','2003-10-01','Male','7559458988','C-1/2:2,New Avdhut C.H.S, Sector 07 , Sanpada',14,NULL,'2026-02-07'),(3,10,'3350','Anish','Bhalerao','2003-06-14','Male','9702753211','S-s-1.Room No-634,sec-15,koparkhairne,navi mumbai',14,NULL,'2026-02-15'),(4,11,'3311','Rucha','Mhatre','2007-10-24','Female','9321486029','sai krupa app sector 20 nerul ,Navi Mumbai',14,NULL,'2026-02-16'),(5,12,'3312','Aarya','Patil','2007-07-07','Female','9321386739','Vitava koliwada Thane',14,NULL,'2026-02-16'),(6,13,'3351','Om','Jadhav','2007-05-14','Male','9657618337','Sumgal soc hsc,plot-38/A,sector-07,khanda colony,new panvel',14,NULL,'2026-02-16'),(7,14,'3356','Atharva','Narwade','2007-04-19','Male','9321252391','602,Bhaveshwar Height ,plot 87,sec 6,karanjade,panvel',14,NULL,'2026-02-26'),(8,15,'3355','Piyush','Surve','2007-06-25','Male','8104412626','C-23,03 Sidheshwar society gharonda ghansoli sec-9',14,NULL,'2026-02-15'),(9,16,'3318','Piyush','Dhumale','2006-02-23','Male','7900189033','Sai Ganesh CHS, Plotno-b.33,Sector-5, Ghansoli-400701,Navi Mumbai',14,NULL,'2026-02-16'),(10,17,'3361','Bhumika','Nawale','2007-06-29','Female','7499648661','dattaguru society A2/1:9 sector 6 , Nerul Navi Mumbai , 400706',14,NULL,'2026-02-06'),(11,18,'3344','Arya','','2007-06-21','Female','9324597164','Panchavati soc c-83 rno:0:2 sector-06 kalamboli',14,NULL,'2026-02-16'),(12,19,'3342','Shreeya','Pandagale','2007-05-28','Female','8097425552','Atlantic infinity,flat no:302,sector:5,ulwe, navi mumbai',14,NULL,'2026-02-02'),(13,20,'3341','Harshita','Mokashi','2007-07-15','Female','7738639636','Yogeshwar Niwas near shamshan bhumi vitawa koliwada, Thane',14,NULL,'2026-02-16'),(14,21,'3345','Saanvi','Rajam','2008-03-15','Female','8454075800','203A,bapu krupa,sec 23,juinager,navi mumbai',14,NULL,'2026-02-01'),(15,22,'3343','Vaishnavi','Sankpal','2007-04-15','Female','9322472033','107&108 ashirwad complex near shiv temple ,kalher ,purna thane .',14,NULL,'2026-02-16'),(16,23,'3352','Laksh','bhosle','2006-10-01','Male','9372828018','dhyneshwar nagar thane west\n',14,NULL,'2026-02-16'),(17,24,'3348','Unnati','Khairnar','2006-12-31','Female','9653407683','g-603 , Arabiana , casa rio , palava city , dombivali east',14,NULL,'2026-02-01'),(19,26,'3321','Shridhar','Dalvi','2007-06-05','Male','9922991569','Mhalhar Park A wing 404 Chinchpada road kalyan east',14,NULL,'2026-02-16'),(20,27,'3326','Roshan','Jadhav','2007-04-02','Male','9594381448','shree vinayak soc,sector-14,plot-A7,Room No:17,Kalamboli',14,NULL,'2026-02-01'),(21,28,'3327','Samarth','Gosavi','2007-03-31','Male','9987318292','2B/402, Chhtrapati shivaji maharaj CHS,PMGP Colony,Mankhurd',9,NULL,'2026-02-03'),(22,29,'3340','Omkar','Ghutukade','2006-02-09','Male','8291024714','hiraji govandaji chawl no.3 room no.14 T.J road sewri west mumbai',14,NULL,'2026-02-01'),(23,30,'3335','Om','Darekar','2007-06-02','Male','8452053607','Shivam Society B-4/A wing -304 sector 6 (Nerul)',14,NULL,'2026-02-16'),(24,31,'3332','Aryan','Gaikwad','2007-07-04','Male','9152307525','Navi Mumbai Sanpada',14,NULL,'2026-02-16'),(25,32,'3333','Sakshant','Patil','2007-03-18','Male','9820421040','Panvel, Navi Mumbai',14,NULL,'2026-02-16'),(26,33,'3334','Viraj','Rajput','2007-03-01','Male','9423421979','Kharghar navi mumbai',14,NULL,'2026-02-16'),(27,42,'2201','Rohan','Mahtre','2007-01-01','Male','9137295939','BVIT',8,NULL,NULL),(28,43,'2202','Aditiya','Shedge','2007-02-02','Male','9137295939','BVIT',8,NULL,NULL),(29,44,'2203','Sakshi','Kadam','2007-03-03','Female','9137295939','BVIT',8,NULL,NULL),(30,45,'2205','Minakshi','Patil','2007-05-02','Female','9137295939','BVIT',8,NULL,NULL),(31,46,'2206','Sham','Rao','2007-12-13','Male','9137295939','BVIT',8,NULL,NULL),(32,47,'2207','Ganesh','Singh','2008-04-12','Male','9137295939','BVIT',8,NULL,NULL),(33,48,'2209','Usman','Shaikh','2005-09-08','Male','9137295939','BVIT',8,NULL,NULL),(34,49,'2210','Asif','Khan','2006-03-02','Male','9137295939','BVIT',8,NULL,NULL),(35,50,'2212','Imran','Khan','2007-12-09','Male','9137295939','BVIT',8,NULL,NULL),(36,51,'2213','Nihal','Shaikh','2005-06-18','Male','9137295939','BVIT',8,NULL,NULL),(37,52,'2215','Moin','Khan','2007-09-15','Male','9137295939','BVIT',9,NULL,NULL),(38,53,'2244','Sadik','Khan','2007-12-23','Male','9137295939','BVIt',9,NULL,NULL),(39,54,'2266','Rehan','Shaikh','2005-10-09','Male','9137295939','BVIT',9,NULL,NULL),(40,55,'2285','Vedant','Patil','2008-06-15','Male','9137295939','BVIT',9,NULL,NULL),(41,56,'2256','Sam','Altman','2005-04-15','Male','9137295939','BVIT',9,NULL,NULL),(42,57,'2289','Sheetal','Thakur','2006-08-12','Male','9137295939','BVIT',9,NULL,NULL),(43,58,'2277','Pooja','Hegde','2004-08-02','Male','9137295939','BVIT',9,NULL,NULL),(44,59,'2283','Anup','Patil','2008-05-04','Male','9137295939','BVIT',9,NULL,NULL),(45,60,'2255','Elon','Musk','2008-11-12','Male','9137295939','BVIT',9,NULL,NULL),(46,62,'3302','Habib','Mansuri','2006-09-13','Male','9137295939','Navi mumbai\r\nNavi mumbai',14,NULL,NULL);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subjects`
--

DROP TABLE IF EXISTS `subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subjects` (
  `subject_id` int NOT NULL AUTO_INCREMENT,
  `subject_name` varchar(100) NOT NULL,
  `subject_code` varchar(20) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`subject_id`),
  UNIQUE KEY `subject_code` (`subject_code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subjects`
--

LOCK TABLES `subjects` WRITE;
/*!40000 ALTER TABLE `subjects` DISABLE KEYS */;
INSERT INTO `subjects` VALUES (1,'DFH','316315','Digital Forensic & Ethical Hacking'),(2,'NIS','102','Network And Information Security'),(3,'CSS','103','Client Side Scripting'),(4,'Management','104','Management Studies'),(5,'ETI','106','Emerging Trends in Artifical Intelligence'),(6,'SFT','108','Software Testing'),(7,'MAD','100','Mobile Application Development');
/*!40000 ALTER TABLE `subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `submission_components`
--

DROP TABLE IF EXISTS `submission_components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `submission_components` (
  `component_id` int NOT NULL AUTO_INCREMENT,
  `subject_id` int NOT NULL,
  `exam_id` int DEFAULT NULL,
  `type_id` int NOT NULL,
  `component_name` varchar(50) NOT NULL,
  `max_marks` int NOT NULL DEFAULT '10',
  `component_order` int DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`component_id`),
  KEY `subject_id` (`subject_id`),
  KEY `exam_id` (`exam_id`),
  KEY `type_id` (`type_id`),
  CONSTRAINT `submission_components_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  CONSTRAINT `submission_components_ibfk_2` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE SET NULL,
  CONSTRAINT `submission_components_ibfk_3` FOREIGN KEY (`type_id`) REFERENCES `submission_types` (`type_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `submission_components`
--

LOCK TABLES `submission_components` WRITE;
/*!40000 ALTER TABLE `submission_components` DISABLE KEYS */;
INSERT INTO `submission_components` VALUES (1,1,1,1,'Manual 1',10,1,'2026-03-10 11:52:20'),(2,1,1,1,'Manual 2',10,2,'2026-03-10 11:52:20'),(3,1,1,1,'Manual 3',10,3,'2026-03-10 11:52:20'),(4,1,1,2,'Assignment 1',10,1,'2026-03-10 11:52:20'),(5,1,1,2,'Assignment 2',10,2,'2026-03-10 11:52:20'),(6,1,1,3,'Viva',10,1,'2026-03-10 11:52:20'),(7,1,1,3,'Journal',10,2,'2026-03-10 11:52:20');
/*!40000 ALTER TABLE `submission_components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `submission_marks`
--

DROP TABLE IF EXISTS `submission_marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `submission_marks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `exam_id` int DEFAULT NULL,
  `component_id` int NOT NULL,
  `marks` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_student_component` (`student_id`,`subject_id`,`exam_id`,`component_id`),
  KEY `subject_id` (`subject_id`),
  KEY `exam_id` (`exam_id`),
  KEY `component_id` (`component_id`),
  CONSTRAINT `submission_marks_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `submission_marks_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  CONSTRAINT `submission_marks_ibfk_3` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE SET NULL,
  CONSTRAINT `submission_marks_ibfk_4` FOREIGN KEY (`component_id`) REFERENCES `submission_components` (`component_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `submission_marks`
--

LOCK TABLES `submission_marks` WRITE;
/*!40000 ALTER TABLE `submission_marks` DISABLE KEYS */;
/*!40000 ALTER TABLE `submission_marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `submission_types`
--

DROP TABLE IF EXISTS `submission_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `submission_types` (
  `type_id` int NOT NULL AUTO_INCREMENT,
  `subject_id` int NOT NULL,
  `exam_id` int DEFAULT NULL,
  `type_name` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `unique_type_subject` (`subject_id`,`exam_id`,`type_name`),
  KEY `exam_id` (`exam_id`),
  CONSTRAINT `submission_types_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  CONSTRAINT `submission_types_ibfk_2` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `submission_types`
--

LOCK TABLES `submission_types` WRITE;
/*!40000 ALTER TABLE `submission_types` DISABLE KEYS */;
INSERT INTO `submission_types` VALUES (1,1,1,'Manual','2026-03-10 11:52:00'),(2,1,1,'Assignment','2026-03-10 11:52:00'),(3,1,1,'SLA','2026-03-10 11:52:00');
/*!40000 ALTER TABLE `submission_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `submissions`
--

DROP TABLE IF EXISTS `submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `submissions` (
  `submission_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  `subject_id` int DEFAULT NULL,
  `activity_name` varchar(100) DEFAULT NULL,
  `submitted` tinyint(1) DEFAULT '0',
  `submission_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`submission_id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `submissions`
--

LOCK TABLES `submissions` WRITE;
/*!40000 ALTER TABLE `submissions` DISABLE KEYS */;
INSERT INTO `submissions` VALUES (4,1,14,1,'SLA',1,'2026-03-11 02:08:45'),(5,1,14,1,'xyz',1,'2026-03-11 05:22:44'),(56,1,14,1,'Assignment',1,'2026-03-13 09:18:31'),(57,46,14,1,'Assignment',1,'2026-03-13 09:18:31'),(58,10,14,1,'Assignment',1,'2026-03-13 09:18:31');
/*!40000 ALTER TABLE `submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_tasks`
--

DROP TABLE IF EXISTS `teacher_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_tasks` (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  `subject_id` int DEFAULT NULL,
  `task_date` date DEFAULT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `description` text,
  `duration` int DEFAULT NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_tasks`
--

LOCK TABLES `teacher_tasks` WRITE;
/*!40000 ALTER TABLE `teacher_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `teacher_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teachers` (
  `teacher_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `employee_id` varchar(20) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `address` text,
  `subject_id` int DEFAULT NULL,
  PRIMARY KEY (`teacher_id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_teacher_subject` (`subject_id`),
  CONSTRAINT `fk_teacher_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE SET NULL,
  CONSTRAINT `teachers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES (5,35,'EMP003','Reena','Miss','9324644612','Digital Forensic and Ethical Hacking',1),(8,38,'EMP002','MAN','Sir','9137295939','BVIT',4),(9,39,'EMP004','Harshali','Miss','9137295939','BVIT',6),(10,40,'EMP005','Dipali','Miss','9137295939','BVIT',3),(11,41,'EMP006','Sujata','Miss','9137295939','BVIT',5),(12,63,'EMP001','Shilpa','Miss','9856785610',NULL,NULL);
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timetables`
--

DROP TABLE IF EXISTS `timetables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timetables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `class_id` int NOT NULL,
  `teacher_id` int NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_type` varchar(100) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timetables`
--

LOCK TABLES `timetables` WRITE;
/*!40000 ALTER TABLE `timetables` DISABLE KEYS */;
INSERT INTO `timetables` VALUES (1,8,2,'1771252502320_Admin DB with minimized Sidebar.png','image/png','2026-02-16 14:35:02');
/*!40000 ALTER TABLE `timetables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` enum('admin','teacher','student','parent') NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'parent1','parent123','parent1@school.com','parent','active','2025-08-02 16:03:45','2025-08-02 16:03:45'),(4,'student3','pass123','student3@school.com','student','active','2025-12-09 07:35:15','2025-12-09 07:35:15'),(6,'Arc','12345','arc@gmail.com','admin','active','2026-01-02 22:27:27','2026-01-02 22:27:27'),(7,'admin','admin123','admin@gmail.com','admin','active','2026-01-03 14:43:35','2026-01-03 14:43:35'),(8,'aryan','1234','aryangangrade310@gmail.com','student','active','2026-02-16 04:32:09','2026-02-26 09:35:54'),(9,'2000270407','9321486029','atkariprajwal01@gmail.com','student','active','2026-02-16 04:34:49','2026-02-28 04:14:42'),(10,'23150940395','9321486029','anishbhalerao4@gmail.com','student','active','2026-02-16 04:37:32','2026-02-28 04:20:14'),(11,'23150940557','9321486029','mhatrerucha24@gmail.com','student','active','2026-02-16 04:39:33','2026-02-16 04:39:33'),(12,'23150940447','9321486029','patilaarya777@gmail.com','student','active','2026-02-16 04:42:02','2026-02-28 04:10:47'),(13,'23150940573','9321486029','omjadhav21225@gmail.com','student','active','2026-02-16 04:44:44','2026-02-28 04:17:46'),(14,'23150940504','9321486029','atharva.19047@gmail.com','student','active','2026-02-16 04:47:13','2026-02-28 04:14:51'),(15,'23150940417','9321486029','piyushsurve2506@gmail.com','student','active','2026-02-16 04:49:49','2026-02-28 04:15:03'),(16,'24150940581','9321486029','piyushdhumale07@gmail.com','student','active','2026-02-16 04:51:56','2026-02-28 04:11:15'),(17,'23150940427','9321486029','bhumikanawale6@gmail.com','student','active','2026-02-16 04:54:25','2026-02-28 04:14:33'),(18,'23150940562','9321486029','aryadeshmukh701@gmail.com','student','active','2026-02-16 04:56:58','2026-02-28 04:20:46'),(19,'23150940506','9321486029','varshapandagale14@gmail.com','student','active','2026-02-16 04:59:13','2026-02-28 04:20:04'),(20,'23150940513','9321486029','harshita15mokashi@gmail.com','student','active','2026-02-16 05:01:09','2026-02-28 04:19:54'),(21,'23150940564','9321486029','saanvirajam@gmail.com','student','active','2026-02-16 05:03:28','2026-02-28 04:20:39'),(22,'23150940428','9321486029','vaishnavisankpal2007@gmail.com','student','active','2026-02-16 05:06:02','2026-02-28 04:21:19'),(23,'2200270209','9321486029','bhosalelaqksh@gmail.com','student','active','2026-02-16 05:07:53','2026-02-28 04:15:30'),(24,'23150940508','9321486029','khairnarunnati31@gmail.com','student','active','2026-02-16 05:10:36','2026-02-28 04:20:24'),(25,'23150940565','9321577169','yash20.modsing@gmail.com','student','active','2026-02-16 05:17:06','2026-02-16 05:17:06'),(26,'23150940503','9321486029','shridhardalvi9922@gmail.com','student','active','2026-02-16 05:19:09','2026-02-28 04:11:34'),(27,'23150940446','9321486029','rj339591@gmail.com','student','active','2026-02-16 05:22:07','2026-02-28 04:11:56'),(28,'2200270476','123','samarthgosavi92@gmail.com','student','active','2026-02-16 05:27:15','2026-02-28 06:39:49'),(29,'24150940589','9321486029','omkarghutukade926@gmail.com','student','active','2026-02-16 06:01:17','2026-02-28 04:19:45'),(30,'23150940577','9321486029','omdarekar588@gmail.com','student','active','2026-02-16 06:04:17','2026-02-28 04:19:04'),(31,'23150940492','9321486029','aryangaikwad866@gmail.com','student','active','2026-02-16 06:08:07','2026-02-28 04:13:48'),(32,'23150940485','9321486029','sakshant124@gmail.com','student','active','2026-02-16 06:10:12','2026-02-28 04:14:23'),(33,'23150940471','9423421979','virajrajput07@gmail.com','student','active','2026-02-16 06:16:50','2026-02-16 06:16:50'),(35,'DFH','Dfh123','teacher1@gmail.com','teacher','active','2026-02-27 03:32:36','2026-02-27 03:32:36'),(38,'MAN','MAN123','teacher4@gmail.com','teacher','active','2026-02-28 03:44:00','2026-02-28 03:44:00'),(39,'SFT','SFT123','teacher5@gmail.com','teacher','active','2026-02-28 03:50:08','2026-02-28 05:15:51'),(40,'CSS','CSS123','teacher6@gmail.com','teacher','active','2026-02-28 03:51:12','2026-02-28 03:51:12'),(41,'ETI','ETI123','teacher7@gmail.com','teacher','active','2026-02-28 04:01:32','2026-02-28 04:01:32'),(42,'Rohan','rohan@123','rohan@Gmail.com','student','active','2026-02-28 04:09:46','2026-02-28 04:09:46'),(43,'Aditiya','aditiya123','aditiya@gmail.com','student','active','2026-02-28 04:10:52','2026-02-28 04:10:52'),(44,'Sakshi','sakshi@123','sakshi@gmail.com','student','active','2026-02-28 04:12:12','2026-02-28 04:12:12'),(45,'Minakshi','minakshi@123','minakshi@gmail.com','student','active','2026-02-28 04:13:25','2026-02-28 04:13:25'),(46,'Sham','sham@123','sham@gmail.com','student','active','2026-02-28 04:14:22','2026-02-28 04:14:22'),(47,'Ganesh','ganesh@123','ganesh@gmail.com','student','active','2026-02-28 04:15:31','2026-02-28 04:15:31'),(48,'Usman','usman@123','usman@gmail.com','student','active','2026-02-28 04:16:47','2026-02-28 04:16:47'),(49,'Asif','asif@123','asif@gmail.com','student','active','2026-02-28 04:17:49','2026-02-28 04:17:49'),(50,'Imran','imran@123','imran@gmail.com','student','active','2026-02-28 04:18:44','2026-02-28 04:18:44'),(51,'Nihal','nihal@123','nihal@gmail.com','student','active','2026-02-28 04:19:51','2026-02-28 04:19:51'),(52,'Moin','moin@123','moin@gmail.com','student','active','2026-02-28 04:21:41','2026-02-28 04:21:41'),(53,'Sadik','sadik@123','sadik@gmail.com','student','active','2026-02-28 04:22:36','2026-02-28 04:22:36'),(54,'Rehan','rehan@123','rehan@gmail.com','student','active','2026-02-28 04:23:26','2026-02-28 04:23:26'),(55,'Vedant','vedan@123','vedan@gmail.com','student','active','2026-02-28 04:25:12','2026-02-28 04:25:12'),(56,'Sam','sam@123','sam@gmail.com','student','active','2026-02-28 04:26:05','2026-02-28 04:26:05'),(57,'Sheetal','sheetal@123','sheetal@gmail.com','student','active','2026-02-28 04:27:23','2026-02-28 04:27:23'),(58,'Pooja','pooja@123','pooja@gmail.com','student','active','2026-02-28 04:32:51','2026-02-28 04:32:51'),(59,'Anup','anup@123','anup@gmail.com','student','active','2026-02-28 04:33:47','2026-02-28 04:33:47'),(60,'Elon','elon@123','elon@gmail.com','student','active','2026-02-28 04:34:49','2026-02-28 04:34:49'),(61,'Mahtre','mahtre@123','mahtre@gmail.com','parent','active','2026-02-28 05:08:18','2026-02-28 05:08:18'),(62,'23150940414','9137295939','khusalsayyed@gmail.com','student','active','2026-02-28 05:10:03','2026-02-28 05:10:03'),(63,'NIS','Nis123','teacher10@gmail.co','teacher','active','2026-02-28 05:17:23','2026-02-28 05:17:23'),(70,'admin_ready_01','Pass@123','admin.ready1@test.com','admin','active','2026-03-12 11:15:38','2026-03-12 11:15:38'),(71,'admin_ready_02','Pass@123','admin.ready2@test.com','admin','active','2026-03-12 11:15:38','2026-03-12 11:15:38'),(72,'admin_dup_username','Pass@123','admin.dupuser1@test.com','admin','active','2026-03-12 11:15:38','2026-03-12 11:15:38');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-13 23:27:50
