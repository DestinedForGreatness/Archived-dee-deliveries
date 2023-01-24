

CREATE TABLE IF NOT EXISTS `dee-deliveries` (
  `restaurant` varchar(60) DEFAULT NULL,
  `stored` INT DEFAULT 0,
  PRIMARY KEY (`restaurant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;