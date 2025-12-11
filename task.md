# My Files Feature Implementation

## Database Schema Updates
- [/] Add `cv_type` field to CVs table (generated, optimized, tailored)
- [ ] Create migration script for database changes

## Domain Layer Updates
- [ ] Add `CVType` enum (generated, optimized, tailored)
- [ ] Update `CVModel` to include `cvType` field
- [ ] Update`CVModel` serialization methods

## Data Layer Updates
- [ ] Update `CVRepository` methods to handle `cv_type`
- [ ] Add provider for fetching cover letters for user

## Business Logic Updates
- [ ] Update `CVController.generateCV` to set type as 'generated'
- [ ] Update `CVController.optimizeCV` to set type as 'optimized'
- [ ] Update `CVController.tailorCV` to set type as 'tailored'

## UI Implementation
- [ ] Create `MyFilesScreen` with categorized sections
  - [ ] Generated CVs section
  - [ ] Optimized CVs section
  - [ ] Tailored CVs section
  - [ ] Cover Letters section
- [ ] Add navigation route for My Files screen
- [ ] Update home screen to navigate to My Files

## CV Selection Enhancement
- [ ] Create reusable categorized CV selector widget
- [ ] Update `TailorCVScreen` to use categorized selector
- [ ] Update `OptimizeCVScreen` to use categorized selector
- [ ] Update `GenerateCoverLetterScreen` to use categorized selector

## Localization
- [ ] Add localization strings for My Files screen
- [ ] Add strings for CV type categories
