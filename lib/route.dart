import '../screen/bodystats/body_measurement_history.dart';
import '../screen/bodystats/caliper_body_history.dart';
import '../screen/bodystats/progress_photo_history.dart';
import '../screen/dashboard/goals/goal_exercise_list.dart';
import '../screen/navigation/achievements/achievements.dart';
import '../screen/navigation/change_password.dart';
import '../screen/onboarding/splash_screen.dart';
import '../screen/program_library/custom_exercise.dart';
import 'package:flutter/material.dart';

import './design_router.dart';
import './screen/onboarding/opening.dart';
import './screen/onboarding/sign_in.dart';
import './screen/onboarding/sign_up.dart';
import './screen/onboarding/sign_up_form.dart';
import './screen/onboarding/welcome_page.dart';
import './screen/navigation/navigation.dart';
import './screen/navigation/profile.dart';
import './screen/navigation/edit_profile.dart';
import './screen/navigation/edit_profile_info.dart';
import './screen/navigation/settings.dart';
import './screen/navigation/sync_devices.dart';
import './screen/bodystats/bs_menu.dart';
import './screen/video_tutorial/video_tutorial.dart';
import './screen/bodystats/compare_photo.dart';
import './screen/onboarding/forgot_password.dart';
import './screen/bodystats/caliper_body.dart';
import './screen/bodystats/progress_photo.dart';
import './screen/bodystats/body_measurement.dart';
import './screen/program_library/program_library.dart';
import './screen/program_library/program_library_categories.dart';
import './screen/program_library/fitness_goals.dart';
import './screen/program_library/filtered_programs.dart';
import './screen/program_library/filter_page.dart';
import './screen/program_library/program_overview.dart';
import './screen/program_library/program_details.dart';
import './screen/program_library/add_program.dart';
import './screen/program_library/create_new_program.dart';
import './screen/program_library/new_program.dart';
import './screen/program_library/phase_detail.dart';
import './screen/program_library/week_detail.dart';
import './screen/program_library/add_new_workout.dart';
import './screen/program_library/workout_day.dart';
import './screen/program_library/workout_log.dart';
import './screen/program_library/exercise_list.dart';
import './screen/program_library/exercise_detail.dart';
import './screen/program_library/workout_log_notes.dart';
import './screen/planner/planner.dart';
import './screen/planner/add_workout.dart';
import './screen/program_library/fitness_featured.dart';
import './screen/program_library/bookmarks.dart';
import './screen/program_library/running_detail.dart';
import './screen/dashboard/goals/set_goals.dart';
import './screen/navigation/friend_profile.dart';
import './screen/health_stats/health_stats.dart';
import './screen/health_stats/fitness_score.dart';
import './screen/health_stats/nutrition_stats.dart';
import './screen/health_stats/calorie_goals_menu.dart';
import './screen/health_stats/calorie_goal.dart';
import './screen/health_stats/calorie_periodisation.dart';
import './screen/health_stats/step_stats.dart';
import './screen/health_stats/body_weight.dart';
import './screen/health_stats/bodyfat.dart';
import './screen/health_stats/sleep_stats.dart';
import './screen/health_stats/vo2_max.dart';
import './screen/health_stats/resting_hr.dart';
import './screen/exercise_stats/exercise.dart';

class Routes {
  static final Map<String, WidgetBuilder> _routes = {
    "/design": (context) => DesignRouter(),
    "/opening": (context) => OpeningPage(),
    "/welcome": (context) => WelcomePage(),
    "/signin": (context) => SignInPage(),
    "/signup": (context) => SignUpPage(),
    "/signupform": (context) => SignUpForm(),
    "/forgot_password": (context) => ForgotPassword(),
    "/navigation": (context) => NavigationPage(),
    "/profile": (context) => Profile(),
    "/friend-profile": (context) => FriendProfile(),
    "/edit_profile": (context) => EditProfile(),
    "/edit_profile_info": (context) => EditProfileInfo(),
    "/change_password": (context) => ChangePassword(),
    "/drawer_settings": (context) => Settings(),
    "/sync_devices": (context) => SyncDevices(),
    "/achievements": (context) => AchievementsScreen(),
    "/video_tutorial": (context) => VideoTutorialPage(),
    "/bs_menu": (context) => BodyStatsMenu(),
    "/caliper_bodyfat": (context) => CaliperBodyFatPage(),
    "/body_measurement": (context) => BodyMeasurementPage(),
    "/progress_photo": (context) => ProgressPhotoPage(),
    "/compare-photo": (context) => ComparePhoto(),
    "/program_library": (context) => ProgramLibrary(),
    "/program_categories": (context) => ProgramLibraryCategories(),
    "/fitness_goals": (context) => FitnessGoals(),
    "/fitness_featured": (context) => FitnessFeatured(),
    "/filtered_programs": (context) => FilteredPrograms(),
    "/filter_page": (context) => FilterPage(),
    "/program_overview": (context) => ProgramOverview(),
    "/program_details": (context) => ProgramDetails(),
    "/add_program": (context) => AddProgram(),
    "/create_new_program": (context) => CreateNewProgram(),
    "/new_program": (context) => NewProgram(),
    "/phase_detail": (context) => PhaseDetail(),
    "/week_detail": (context) => WeekDetail(),
    "/workout_day": (context) => WorkoutDay(),
    "/add_new_workout": (context) => AddNewWorkout(),
    "/workout_log": (context) => WorkoutLog(),
    "/workout_notes": (context) => WorkoutLogNotes(),
    "/goal_exercise_list": (context) => GoalExerciseList(),
    "/exercise_list": (context) => ExerciseList(),
    "/exercise_detail": (context) => ExerciseDetail(),
    "/planner": (context) => Planner(),
    "/add_workout": (context) => AddWorkout(),
    "/bookmarks": (context) => Bookmarks(),
    "/running": (context) => RunningDetailPage(),
    "/set_goals": (context) => SetGoals(),
    "/health_stats": (context) => HealthStats(),
    "/fitness_score": (context) => FitnessScore(),
    "/nutrition_stats": (context) => NutritionStats(),
    "/calorie_goals_menu": (context) => CalorieGoalsMenu(),
    "/calorie_periodisation": (context) => CaloriePeriodisation(),
    "/calorie_goal": (context) => CalorieGoal(),
    "/step_stats": (context) => StepStats(),
    "/body_weight": (context) => BodyWeight(),
    "/bodyfat": (context) => Bodyfat(),
    "/sleep_stats": (context) => SleepStats(),
    "/vo2_max": (context) => Vo2Max(),
    "/resting_hr": (context) => RestingHR(),
    "/exercise_stats": (context) => ExerciseStats(),
    "/caliper_history": (context) => CaliperBodyHistory(),
    "/body_measurement_history": (context) => BodyMeasurementHistory(),
    "/progress_photo_history": (context) => ProgressPhotoHistory(),
    "/splash_screen": (context) => SplashScreen(),
    "/custom_exercise": (context) => AddCustomExercise(),
  };
  static Map<String, WidgetBuilder> getAll() => _routes;
}
