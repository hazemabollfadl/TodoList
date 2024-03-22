import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    
    let realm=try! Realm()
    
    var categoryArray: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.rowHeight  = 60
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar=navigationController?.navigationBar else{fatalError("Navigation Bar doesn't exist!")}
        navBar.backgroundColor = .systemBackground
        navBar.largeTitleTextAttributes=[NSAttributedString.Key.foregroundColor: UIColor(named: "MyColorSet")!]
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textResult = UITextField()
        
        let alert=UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert )
        
        let action=UIAlertAction(title: "Add Category", style: .default) { action in
            
            //what happens when the user clicks add Category
            if textResult.text==""{
                let alert=UIAlertController(title: "Warning", message: "No Categories Were Added", preferredStyle: .alert)
                let action=UIAlertAction(title: "Ok", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }else{
                
                //stores added item in the array of categoryArray
                let newCategory = Category()
                newCategory.title = textResult.text!
                newCategory.colorOfCell=UIColor.init(randomFlatColorOf: .dark).hexValue()
                
                
                self.save(the: newCategory)
            }
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Create New Category"
            textResult=alertTextField
        }
        
        present(alert, animated: true)
    }
    
    //MARK: - UITableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell=UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")
        
        let itemList=categoryArray?[indexPath.row]
        cell.textLabel?.text=itemList?.title ?? "No Categories Added yet"
        
        cell.backgroundColor=UIColor(hexString: (itemList?.colorOfCell) ?? "5856D6")
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        
        return cell
    }
    
    //MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC=segue.destination as! TodoListVC
        
        if let indexPath=tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory=categoryArray?[indexPath.row]
        }
    }
    
    //Swipe to delet category
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let safeCategoryArray=categoryArray?[indexPath.row]{
                do{
                    try realm.write {
                        realm.delete(safeCategoryArray )
                    }
                }catch{
                    print("Couldn't delete Item: \(error)")
                }
            }
        }
        tableView.reloadData()
    }
    
    
    
    //MARK: - Data Manipulation Methods
    
    func save(the category:Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving the data\(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        //Fetches Data as a Result Container containing bunch of category objects
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}
