def deleteData(uid, d)
  user = User.find_by_id(uid)
  # start = Time.zone.now.midnight
  start = Time.zone.parse(d)
  user.lifestyles.where("end_time > ?", start).delete_all
  user.diets.where("date > ?", start).delete_all
  user.measurements.where("date > ?", start).delete_all
  user.activities.where("end_time > ?", start).delete_all
  user.medications.where("date > ?", start).delete_all
end